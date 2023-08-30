import { SlowBuffer } from 'buffer';
import { Configuration, OpenAIApi } from 'openai'

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);

const system = `
Generate a concise git commit message written in present tense for the following code diff with the given specifications below:
Message language: ja_JP
Commit message must be a maximum of 100 characters.
Exclude anything unnecessary such as translation. Your entire response will be passed directly into git commit.
The output response must be in format: <commit message>
`.trim();

(async () => {
    const input: string[] = [];
    for await (const chunk of process.stdin) {
        input.push(chunk.toString())
    }

    const arr = await Promise.all([...Array(4)].map(async () => {
        const completion = await openai.createChatCompletion({
            model: 'gpt-3.5-turbo',
            messages: [
                { role: 'system', content: system },
                { role: 'user', content: input.join("") },
            ],
        });
        return completion.data.choices[0].message?.content ?? '';
    }));

    console.log("# OpenAI generated commit message");
    console.log(arr
        .map(s => s.trim())
        .filter(s => s.length)
        .join("\n")
        .trim()
        .split("\n")
        .map(s => `# - ${s}`)
        .join("\n")
    );
    console.log("#");
})();
