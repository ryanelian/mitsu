# emerald - Ruby Code Explainer CLI

For the soy latte-powered MacBook enjoyer who has never touched Ruby: this CLI lovingly translates Rails codebase into something your C# / TypeScript brain can process without resolving to extra sugar into your caffeine.

## Setup

### Quick Node setup

```bash
brew install fnm
fnm install
fnm use
npm install -g pnpm
pnpm install
```

1) Copy the example env file and add your secrets like a responsible adult:
```bash
cp .env.example .env
```

2) Edit `.env` and set at least:
```bash
OPENAI_API_KEY=sk-... # required (OpenAI or gateway key. No, you can't have mine. Tokens are expensive)
# Optional: use a proxy/gateway (e.g., OpenRouter)
# OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

emerald loads env vars from the repo-root `.env`.

## What it scans and generates

- Scans `./dynamic-pricing` recursively for Ruby files: `.rb`, `.rake`, `.gemspec`.
- Skips noisy places: `node_modules`, `.git`, `tmp`, `log`, `vendor`.
- Writes to `./dynamic-pricing-docs`:
  - Markdown explanations (default)
  - Commented Ruby (`--mode=comment`) that keeps behavior identical but adds explanations

## Commands

- Generate Markdown explanations:
```bash
pnpm scan
```

- Generate commented Ruby (same code, many more brain-cells):
```bash
pnpm scan:comment
```

## Tips

- Skips empty files and already-processed outputs to save tokens and time.
- Want a clean slate? Delete files under `dynamic-pricing-docs/` and run again.

## Troubleshooting

- "OPENAI_API_KEY environment variable is not set"
  - Ensure `.env` exists at the repo root and contains `OPENAI_API_KEY`.
  - Run commands from the repo root so dotenv loads `.env`.

- Using a gateway (OpenRouter)
  - Set both `OPENAI_BASE_URL` and `OPENAI_API_KEY` in `.env`.

- Output looks too short
  - Some Rails stubs are intentionally tiny. That’s not you, That’s just Ruby template life.
