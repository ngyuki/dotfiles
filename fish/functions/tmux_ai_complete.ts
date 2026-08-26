#!/usr/bin/env node

import { ChildProcess, spawn } from "node:child_process";
import { createWriteStream, WriteStream } from "node:fs";
import { mkdtemp, rm, stat } from "node:fs/promises";
import { request } from "node:http";
import { constants, tmpdir } from "node:os";
import { join } from "node:path";
import { Readable } from "node:stream";
import { finished, pipeline } from "node:stream/promises";
import { setTimeout } from "node:timers/promises";

type Provider = "codex" | "gemini" | "gemini-api" | "agy" | "fake";

const CANDIDATE_SEPARATOR = "<--CANDIDATE-SEPARATOR-->";
const FIELD_SEPARATOR = "<--FIELD-SEPARATOR-->";

const env = process.env;

(async function main() {
    const currentLine = process.argv[2] ?? "";
    const provider = (env.TMUX_AI_COMPLETE_PROVIDER ?? "codex").toLowerCase();
    const historyLines = env.TMUX_AI_COMPLETE_HISTORY_LINES ?? "";

    if (provider !== "codex" && provider !== "gemini" && provider !== "agy" && provider !== "fake" && provider !== "gemini-api") {
        throw new Error("TMUX_AI_COMPLETE_PROVIDER must be codex, gemini, gemini-api, agy");
    }
    if (historyLines && !/^[1-9][0-9]*$/.test(historyLines)) {
        throw new Error("TMUX_AI_COMPLETE_HISTORY_LINES must be a positive integer");
    }
    if (!env.TMUX) {
        throw new Error("not running inside tmux");
    }

    const capture = await tmuxCapturePane(historyLines);

    const prompt = [
        "You generate a command line for the fish shell.",
        "Use the current command line and terminal context below to infer the intended command.",
        "Generate exactly five distinct candidate command lines.",
        `Separate each full candidate with '${CANDIDATE_SEPARATOR}'.`,
        `For each candidate, provide three pieces of information separated by '${FIELD_SEPARATOR}':`,
        "1. The command. If it is long, format it with backslashes (\\) and newlines for readability.",
        "2. A short description of what the command does (as a single line) in Japanese.",
        "3. A detailed explanation of why this command is suggested (as multiple lines) in Japanese.",
        "Do not include any other text or formatting.",
        "",
        "<current_command_line>",
        currentLine,
        "</current_command_line>",
        "",
        "<terminal_context>",
        capture,
        "</terminal_context>",
    ].join("\n");

    const tempDir = await mkdtemp(join(tmpdir(), "tmux-ai-complete-"));
    const sockFile = join(tempDir, "fzf.sock");
    const logFile = join(tempDir, "error.log");
    const logStream = createWriteStream(logFile, { flags: "a" });

    try {
        const abort = new AbortController();
        const fzf = spawn(
            "fzf",
            [
                `--listen=${sockFile}`,
                "--disabled",
                "--no-multi",
                "--prompt=Generating candidates... ",
                '--preview=tail -n +1 -f "$TMUX_AI_COMPLETE_LOG_FILE"',
                `--preview-label=${provider.toUpperCase()}`,
                "--preview-window=top,50%,follow,wrap",
                "--bind=enter:accept-non-empty",
                "--bind=tab:toggle-preview,btab:toggle-preview",
                "--delimiter=\t",
                "--with-nth=1",
                "--read0",
            ],
            {
                stdio: ["pipe", "pipe", "inherit"],
                env: { ...env, TMUX_AI_COMPLETE_LOG_FILE: logFile },
            },
        );

        const [commands, fzfCode, selected] = await Promise.all([
            (async () => {
                await waitForSocket(sockFile, fzf);
                await fzfAction(sockFile, "refresh-preview+change-preview-window(follow)");
                try {
                    const output = await invokeAI(provider, prompt, logStream, abort);
                    const formatted = formatCandidates(output);
                    if (formatted.commands.size === 0) {
                        throw new Error(`${provider} returned no valid candidates. output:\n${output}`);
                    }
                    if (fzf.exitCode === null) {
                        fzf.stdin.end(formatted.text);
                        await finished(fzf.stdin);
                        await fzfAction(
                            sockFile,
                            `change-prompt(Command> )+enable-search+first+change-preview-window(top,50%,wrap)+change-preview(printf "%s\n\n%s" {2} {1})`
                        );
                    }
                    return formatted.commands;
                } catch (err) {
                    logStream.write(`\n${String(err)}\n`);
                    if (fzf.exitCode === null) {
                        await fzfAction(sockFile, `change-prompt(${provider} failed - Esc to close> )+disable-search`);
                    }
                    return null;
                }
            })(),
            (async () => {
                try {
                    return await waitCloseChildProcess(fzf);
                } finally {
                    abort.abort();
                }
            })(),
            (async () => {
                const stdout = await waitReadableStreamFinished(fzf.stdout);
                return stdout.trimEnd();
            })(),
        ]);
        if (fzfCode === 0 && selected && commands) {
            const command = commands.get(selected);
            if (!command) {
                throw new Error("selected candidate was not found");
            }
            process.stdout.write(command);
        }
        if (fzfCode !== 0 && fzfCode !== 1 && fzfCode !== 130) {
            process.exitCode = fzfCode;
        }
    } finally {
        logStream.end();
        await finished(logStream);
        await rm(tempDir, { recursive: true, force: true });
    }
})();

async function waitCloseChildProcess(child: ChildProcess): Promise<number> {
    return new Promise((resolve, reject) => {
        child.once("error", reject);
        child.once("close", (code, signal) => resolve(code ?? (signal ? constants.signals[signal] + 128 : 255)));
    });
}

async function waitReadableStreamFinished(stream: Readable): Promise<string> {
    let output = "";
    stream.on("data", (chunk: Buffer) => (output += chunk));
    await finished(stream);
    return output;
}

async function tmuxCapturePane(historyLines: string) {
    const args = ["capture-pane", "-p", "-e", "-J", ...(historyLines ? ["-S", `-${historyLines}`] : [])];
    const child = spawn("tmux", args, { stdio: ["ignore", "pipe", "pipe"] });
    const [code, stdout, stderr] = await Promise.all([
        waitCloseChildProcess(child),
        waitReadableStreamFinished(child.stdout),
        waitReadableStreamFinished(child.stderr),
    ]);
    if (code !== 0) {
        process.stderr.write(`Failed to tmux capture pane: ${stderr.trim()}\n`);
        process.exit(code);
    }
    return stdout;
}

function formatCandidates(raw: string) {
    const commands = new Map<string, string>();
    const candidates = raw.split(CANDIDATE_SEPARATOR).filter(v => v.trim());

    const lines = candidates.map((candidate) => {
        const [command, summary, reason] = candidate.split(FIELD_SEPARATOR).map(v => v.trim());
        if (!command || !summary || !reason) {
            return null;
        }
        const description = `${summary}\n\n${reason}`.replace(/^/mg, "# ");
        const line = `${command}\t${description}`;
        commands.set(line, command);
        return line;
    });

    const text = lines.filter(v => v !== null).join("\0");
    return { commands, text };
}

async function waitForSocket(file: string, fzf: ChildProcess) {
    while (fzf.exitCode === null) {
        try {
            if ((await stat(file)).isSocket()) {
                return;
            }
        } catch {}
        await setTimeout(50);
    }
    throw new Error("fzf closed before its listen server started");
}

function fzfAction(socketPath: string, action: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const req = request({
            socketPath,
            path: "/",
            method: "POST",
            headers: { "Content-Length": Buffer.byteLength(action) },
        });
        req.once("error", reject);
        req.on("response", (response) => {
            response.resume();
            response.once("end", () => {
                if (response.statusCode && response.statusCode >= 200 && response.statusCode < 300) {
                    resolve();
                } else {
                    reject(new Error(`fzf listen request failed: ${response.statusCode ?? "unknown"}`));
                }
            });
        });
        req.end(action);
    });
}

async function invokeAI(provider: Provider, prompt: string, logStream: WriteStream, abort: AbortController) {
    if (provider === "gemini-api") {
        return await requestToGeminiApi(prompt, abort);
    } else {
        const invocation = buildAICommand(provider, prompt);
        const child = spawn(invocation.command, invocation.args, {
            stdio: ["pipe", "pipe", "pipe"],
        });
        abort.signal.addEventListener("abort", () => child.kill());
        child.stdin.end(invocation.stdin);
        const [code, stdout] = await Promise.all([
            waitCloseChildProcess(child),
            waitReadableStreamFinished(child.stdout),
            pipeline(child.stderr, logStream),
        ]);
        if (code !== 0) {
            throw new Error(`${provider} exited with status ${code}`);
        }
        return stdout;
    }
}

function buildAICommand(provider: Exclude<Provider, "gemini-api">, prompt: string) {
    if (provider === "codex") {
        const model = env.TMUX_AI_COMPLETE_CODEX_MODEL?.trim() || "gpt-5.6-luna";
        const effort = env.TMUX_AI_COMPLETE_CODEX_EFFORT?.trim() || "none";
        return {
            command: "codex",
            stdin: prompt,
            args: [
                "exec",
                `--model=${model}`,
                `--config=model_reasoning_effort=${effort}`,
                "--ephemeral",
                "--skip-git-repo-check",
                "--sandbox=read-only",
                "--color=always",
                "-",
            ],
            env: {
                ...env,
                RUST_LOG: "debug",
            },
        };
    } else if (provider === "gemini") {
        const model = env.TMUX_AI_COMPLETE_GEMINI_MODEL?.trim() || "prompt-completion";
        return {
            command: "gemini",
            stdin: prompt,
            args: [
                `--model=${model}`,
                "--skip-trust",
                "--output-format=text",
                "--approval-mode=plan",
                "--prompt=",
            ],
        };
    } else if (provider === "agy") {
        const model = env.TMUX_AI_COMPLETE_AGY_MODEL?.trim() || "gemini-3.7-flash-low";
        return {
            command: "agy",
            stdin: "",
            args: [
                `--model=${model}`,
                "--mode=plan",
                "--sandbox",
                "--prompt",
                prompt,
            ],
        };
    } else {
        const candidate = [
            [
                "echo -e \\\n  hello world",
                "short desc",
                "long reason\nhello world",
            ],
            [
                "echo hello world",
                "short desc",
                "long reason\nhello world",
            ],
        ].map(fields => fields.join(FIELD_SEPARATOR)).join(CANDIDATE_SEPARATOR);
        process.env.TMUX_AI_COMPLETE_FAKE_CANDIDATE = candidate;
        return {
            command: "/bin/sh",
            stdin: "",
            args: ["-c", `sleep 1; printf %s "$TMUX_AI_COMPLETE_FAKE_CANDIDATE"`],
        };
    }
}

async function requestToGeminiApi(prompt: string, abort: AbortController): Promise<string> {
    const apiKey = await lookupGeminiApiKey();
    const model = env.TMUX_AI_COMPLETE_GEMINI_API_MODEL?.trim() || "gemini-3.5-flash-lite";
    const body = JSON.stringify({ model, input: prompt, store: false });
    const res = await fetch(`https:/generativelanguage.googleapis.com/v1/interactions`, {
        method: "POST",
        headers: {
            "x-goog-api-key": apiKey,
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(body).toString(),
        },
        body,
        signal: abort.signal,
    });
    if (res.status < 200 || res.status >= 300) {
        throw new Error(`Gemini API request failed with status ${res.status}`);
    }
    const data = await res.json() as { steps: { type: string, content: { text: string }[] }[] };
    const text = data.steps.filter(o => o.type === "model_output").map(o => o.content).flat().map(o => o.text).find(v => v);
    if (!text) {
        throw new Error(`Failed to extract text from Gemini API with response ${JSON.stringify(data)}`);
    }
    return text;
}

async function lookupGeminiApiKey() {
    const apiKey = env.TMUX_AI_COMPLETE_GEMINI_API_KEY ?? env.GEMINI_API_KEY;
    if (!apiKey) {
        throw new Error("GEMINI_API_KEY environment variable is not set");
    }
    const match = apiKey.match(/^keyring:([^=]+)=(.+)$/);
    if (!match) {
        return apiKey;
    }
    const [, attr, value] = match;
    const child = spawn("secret-tool", ["lookup", attr, value], {
        stdio: ["ignore", "pipe", "inherit"],
    });
    const [code, stdout] = await Promise.all([
        waitCloseChildProcess(child),
        waitReadableStreamFinished(child.stdout),
    ]);
    if (code !== 0) {
        throw new Error(`secret-tool lookup failed with status ${code}`);
    }
    return stdout.trim();
}
