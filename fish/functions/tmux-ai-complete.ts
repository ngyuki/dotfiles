#!/usr/bin/env node

import { spawn } from "node:child_process";
import { appendFile, mkdtemp, rm, stat, writeFile } from "node:fs/promises";
import { request } from "node:http";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { finished } from "node:stream/promises";

type Provider = "codex" | "gemini" | "agy" | "fake";

const CANDIDATE_SEPARATOR = "<--CANDIDATE-SEPARATOR-->";
const FIELD_SEPARATOR = "<--FIELD-SEPARATOR-->";

const env = process.env;
const currentLine = process.argv[2] ?? "";
const provider = (env.TMUX_AI_COMPLETE_PROVIDER ?? "codex").toLowerCase();
const historyLines = env.TMUX_AI_COMPLETE_HISTORY_LINES ?? "";

if (provider !== "codex" && provider !== "gemini" && provider !== "agy" && provider !== "fake") {
    fail("TMUX_AI_COMPLETE_PROVIDER must be codex, gemini, or agy", 2);
}
if (historyLines && !/^[1-9][0-9]*$/.test(historyLines)) {
    fail("TMUX_AI_COMPLETE_HISTORY_LINES must be a positive integer", 2);
}
if (!env.TMUX) {
    fail("not running inside tmux");
}

const pane = await run("tmux", ["capture-pane", "-p", "-e", "-J", ...(historyLines ? ["-S", `-${historyLines}`] : [])]);
if (pane.code !== 0) {
    fail(`failed to capture pane: ${pane.stderr.trim()}`, pane.code);
}

const prompt = [
    "You generate a command line for the fish shell.",
    "Use the current command line and terminal context below to infer the intended command.",
    "Generate exactly five distinct candidate command lines.",
    `Separate each full candidate with '${CANDIDATE_SEPARATOR}'.`,
    `For each candidate, provide three pieces of information separated by '${FIELD_SEPARATOR}':`,
    "1. The command. If it is long, format it with backslashes (\\) and newlines for readability.",
    "2. A short description of what the command does (as a single line).",
    "3. A detailed explanation of why this command is suggested (as multiple lines).",
    "Do not include any other text or formatting.",
    "",
    "<current_command_line>",
    currentLine,
    "</current_command_line>",
    "",
    "<terminal_context>",
    pane.stdout,
    "</terminal_context>",
].join("\n");

const tempDir = await mkdtemp(join(tmpdir(), "tmux-ai-complete-"));
const logFile = join(tempDir, "log");
const socketFile = join(tempDir, "fzf.sock");
await writeFile(logFile, "");

let aiProcess: ReturnType<typeof spawn> | undefined;
try {
    const fzf = spawn(
        "fzf",
        [
            `--listen=${socketFile}`,
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

    const controller = (async () => {
        await waitForSocket(socketFile, fzf);
        await postAction(socketFile, "refresh-preview+change-preview-window(follow)");
        try {
            const invocation = buildAICommand(provider, prompt);
            const child = spawn(invocation.command, invocation.args, {
                stdio: ["pipe", "pipe", "pipe"],
            });
            aiProcess = child;
            child.stdin.end(invocation.stdin);

            let output = "";
            const logWrites: Promise<void>[] = [];
            child.stdout.on("data", (chunk: Buffer) => {
                const text = chunk.toString();
                output += text;
            });
            child.stderr.on("data", (chunk: Buffer) => {
                logWrites.push(appendFile(logFile, chunk.toString()));
            });

            const code = await closeCode(child);
            await Promise.all(logWrites);
            if (code !== 0) {
                throw new Error(`${provider} exited with status ${code}`);
            }

            const formatted = formatCandidates(output);
            if (formatted.commands.size === 0) {
                throw new Error(`${provider} returned no valid candidates. output:\n${output}`);
            }

            if (fzf.exitCode === null) {
                fzf.stdin.end(formatted.text);
                await finished(fzf.stdin);
                await postAction(
                    socketFile,
                    `change-prompt(Command> )+enable-search+first+change-preview-window(top,50%,wrap)+change-preview(printf "%s\n\n%s" {2} {1})`
                );
            }
            return formatted.commands;
        } catch (err) {
            await appendFile(logFile, `\n${String(err)}\n`);
            if (fzf.exitCode === null) {
                await postAction(socketFile, `change-prompt(${provider} failed - Esc to close> )+disable-search`);
            }
            return new Map<string, string>();
        }
    })();

    const [fzfCode, selected] = await Promise.all([
        new Promise<number>((resolve, reject) => {
            fzf.once("error", reject);
            fzf.once("close", (code, signal) => resolve(code ?? (signal === "SIGINT" ? 130 : 1)));
        }),
        (async () => {
            let output = "";
            fzf.stdout.on("data", (chunk: Buffer) => (output += chunk));
            await finished(fzf.stdout);
            return output.trimEnd();
        })(),
    ])

    if (aiProcess && aiProcess.exitCode === null) {
        aiProcess.kill();
    }
    const commands = (await controller) ?? new Map<string, string>();

    if (selected) {
        const command = commands.get(selected);
        if (!command) {
            throw new Error("selected candidate was not found");
        }
        process.stdout.write(command);
    }
    if (fzfCode !== 0 && fzfCode !== 1 && fzfCode !== 130) {
        process.exitCode = fzfCode;
    }
} catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`tmux-ai-complete: ${message}\n`);
    process.exitCode = 1;
} finally {
    await rm(tempDir, { recursive: true, force: true });
}

function buildAICommand(provider: Provider, prompt: string) {
    if (provider === "codex") {
        const command = env.TMUX_AI_COMPLETE_CODEX_COMMAND ?? "codex";
        const model = env.TMUX_AI_COMPLETE_CODEX_MODEL?.trim() || "gpt-5.6-luna";
        const effort = env.TMUX_AI_COMPLETE_CODEX_EFFORT?.trim() || "none";
        return {
            command: command,
            stdin: prompt,
            args: [
                "exec",
                `--model=${model}`,
                `--config=model_reasoning_effort=${effort}`,
                "--ephemeral",
                "--skip-git-repo-check",
                "--sandbox",
                "read-only",
                "--color",
                "always",
                "-",
            ],
        };
    } else if (provider === "gemini") {
        const command = env.TMUX_AI_COMPLETE_GEMINI_COMMAND?.trim() || "gemini";
        const model = env.TMUX_AI_COMPLETE_GEMINI_MODEL?.trim() || "prompt-completion";
        return {
            command: command,
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
        const command = env.TMUX_AI_COMPLETE_AGY_COMMAND?.trim() || "agy";
        const model = env.TMUX_AI_COMPLETE_AGY_MODEL?.trim() || "gemini-3.7-flash-low";
        const effort = env.TMUX_AI_COMPLETE_AGY_EFFORT?.trim() || "low";
        return {
            command: command,
            stdin: "",
            args: [
                `--model=${model}`,
                `--effort=${effort}`,
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

async function run(command: string, args: string[]) {
    const child = spawn(command, args, { stdio: ["ignore", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk: Buffer) => (stdout += chunk));
    child.stderr.on("data", (chunk: Buffer) => (stderr += chunk));
    try {
        return { code: await closeCode(child), stdout, stderr };
    } catch (error) {
        return { code: 127, stdout, stderr: error instanceof Error ? error.message : String(error) };
    }
}

function closeCode(child: ReturnType<typeof spawn>): Promise<number> {
    return new Promise((resolve, reject) => {
        child.once("error", reject);
        child.once("close", (code, signal) => resolve(code ?? (signal === "SIGINT" ? 130 : 1)));
    });
}

async function waitForSocket(file: string, fzf: ReturnType<typeof spawn>) {
    while (fzf.exitCode === null) {
        try {
            if ((await stat(file)).isSocket()) return;
        } catch {}
        await new Promise((resolve) => setTimeout(resolve, 50));
    }
    throw new Error("fzf closed before its listen server started");
}

function postAction(socketPath: string, action: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const actionRequest = request(
            {
                socketPath,
                path: "/",
                method: "POST",
                headers: { "Content-Length": Buffer.byteLength(action) },
            },
            (response) => {
                response.resume();
                response.once("end", () => {
                    if (response.statusCode && response.statusCode >= 200 && response.statusCode < 300) {
                        resolve();
                    } else {
                        reject(new Error(`fzf listen request failed: ${response.statusCode ?? "unknown"}`));
                    }
                });
            },
        );
        actionRequest.once("error", reject);
        actionRequest.end(action);
    });
}

function fail(message: string, code = 1): never {
    process.stderr.write(`tmux-ai-complete: ${message}\n`);
    process.exit(code);
}
