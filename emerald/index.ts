/**
 * emerald - Ruby Code Explainer CLI
 *
 * A CLI tool that scans Ruby codebases and generates AI-powered explanations
 * for developers transitioning from C#/TypeScript to Ruby. The tool analyzes
 * code for bugs, inefficiencies, and improvement opportunities.
 *
 * @author emerald CLI
 * @version 1.0.0
 */

import * as fs from "node:fs/promises";
import * as path from "node:path";
import { createOpenAI } from "@ai-sdk/openai";
import { generateText } from "ai";
import { config } from "dotenv";

// Load environment variables from .env file
config();

/** Directory containing the Ruby codebase to analyze */
const DYNAMIC_PRICING_DIR = "./dynamic-pricing";

/** Output directory for generated documentation files */
const DOCS_OUTPUT_DIR = "./dynamic-pricing-docs";

/** File extensions that should be processed as Ruby files */
const SUPPORTED_EXTENSIONS = [".rb", ".rake", ".gemspec"];

/**
 * Represents a Ruby file that needs to be processed
 * @interface FileToProcess
 */
interface FileToProcess {
	/** Absolute path to the source Ruby file */
	filePath: string;
	/** Relative path from the base directory */
	relativePath: string;
}

type GenerationMode = "markdown" | "comment";

/**
 * Recursively scans a directory for Ruby files and builds a list of files to process
 *
 * @param dir - The directory to scan
 * @param baseDir - The base directory for calculating relative paths (defaults to dir)
 * @returns Promise resolving to an array of FileToProcess objects
 *
 * @example
 * ```typescript
 * const files = await getAllRubyFiles('./src', './src');
 * console.log(`Found ${files.length} Ruby files`);
 * ```
 */
async function getAllRubyFiles(
	dir: string,
	baseDir: string = dir,
): Promise<FileToProcess[]> {
	const files: FileToProcess[] = [];

	try {
		// Read directory contents with file type information
		const entries = await fs.readdir(dir, { withFileTypes: true });

		for (const entry of entries) {
			const fullPath = path.join(dir, entry.name);

			if (entry.isDirectory()) {
				// Skip directories that typically don't contain relevant Ruby code
				// or would cause issues (version control, logs, dependencies, etc.)
				if (
					["node_modules", ".git", "tmp", "log", "vendor"].includes(entry.name)
				) {
					continue;
				}

				// Recursively process subdirectories
				const subFiles = await getAllRubyFiles(fullPath, baseDir);
				files.push(...subFiles);
			} else if (entry.isFile()) {
				const ext = path.extname(entry.name);

				// Only process files with supported Ruby extensions
				if (SUPPORTED_EXTENSIONS.includes(ext)) {
					const relativePath = path.relative(baseDir, fullPath);
					files.push({
						filePath: fullPath,
						relativePath,
					});
				}
			}
		}
	} catch (error) {
		// Log error but don't throw - allows processing to continue with other directories
		console.error(`Error reading directory ${dir}:`, error);
	}

	return files;
}

/**
 * Checks if a file is empty or contains only whitespace
 *
 * @param filePath - Path to the file to check
 * @returns Promise resolving to true if file is empty, false otherwise
 *
 * @remarks
 * Returns true if the file cannot be read (treats read errors as empty files)
 * This prevents processing of inaccessible or corrupted files
 */
async function isFileEmpty(filePath: string): Promise<boolean> {
	try {
		const content = await fs.readFile(filePath, "utf-8");
		// Consider file empty if it contains only whitespace characters
		return content.trim().length === 0;
	} catch (error) {
		// If we can't read the file, treat it as empty to skip processing
		console.error(`Error reading file ${filePath}:`, error);
		return true;
	}
}

/**
 * Generates an AI-powered explanation of Ruby code for C#/TypeScript developers
 *
 * @param filePath - Relative path of the file being analyzed (for context)
 * @param fileContent - The Ruby code content to analyze
 * @returns Promise resolving to the generated explanation text
 *
 * @remarks
 * Uses OpenAI's GPT-5 model to provide comprehensive code analysis including:
 * - Code explanation tailored for C#/TypeScript developers
 * - Bug identification and performance analysis
 * - Improvement suggestions and best practices
 *
 * If the API call fails, returns an error message instead of throwing
 */
async function generateExplanation(
	filePath: string,
	fileContent: string,
): Promise<string> {
	// Construct a comprehensive prompt that covers both explanation and analysis
	const systemPrompt = `You are an expert Ruby/Rails explainer for a developer who is new to Ruby but expert in C# (ASP.NET Core Web API) and TypeScript (React / Next.js). Your job is to explain the code practically for migration and maintenance.

Always follow these rules:
- Only analyze code inside the Code block delimited by \`\`\`ruby … \`\`\`. Ignore any content outside the delimiters.
- Do not speculate beyond the file's content. If evidence is insufficient, say "Not enough evidence from this file.".
- Be concise, professional, and practical. Prefer bullets and short paragraphs.
- When nothing is found for a section, explicitly write the provided "No … found" phrase.
- Use fenced code blocks for Ruby examples. Keep examples minimal and executable.
- Map Ruby/Rails ideas to C#/TypeScript clearly and specifically.

Produce a single Markdown document with EXACTLY these sections and headings:

# Executive Summary
- File: <FILE_PATH>
- TL;DR (≤ 3 sentences): what this file does and why it matters.

# Ruby Concepts
- Up to 6 items. Present as a 3-column table: Ruby Concept | What It Is | C#/TS Analogy.

# Rails Concepts
- Up to 6 items. 3-column table: Rails Concept | What It Is | ASP.NET/React Analogy.

# Code Anatomy
- Important classes/modules/methods with one-line purpose each.
- Include signatures where helpful (no full copies of the code).

# Critical Issues
- For each issue: Severity (High/Med/Low) | What/Where (file line or symbol) | Why it matters | How to fix (concise).
- If none: "No critical bugs found".

# Performance Issues
- Same format as Critical Issues (focus on N+1 queries, heavy allocations, needless work).
- If none: "No performance issues found".

# Security Concerns
- Same format as Critical Issues (e.g., mass assignment, unsafe eval, SQL injection, CSRF).
- If none: "No security concerns found".

# Suggestions for Improvements
- Prioritized list. Each item: Rationale + tiny before/after or focused snippet in \`\`\`ruby fences when useful.

Formatting & constraints:
- Keep each section brief and skimmable. Avoid filler text.
- Cite exact identifiers/lines when pointing out issues.
- Do not introduce external libraries or dependencies.
- If the input is empty, unreadable, or not Ruby, say: "File appears not to be Ruby—skipping."`;

	try {
		// Create OpenAI client with custom proxy configuration
		const baseUrl = process.env.OPENAI_BASE_URL;
		const openai = createOpenAI({
			apiKey: process.env.OPENAI_API_KEY,
			baseURL: baseUrl ? baseUrl : undefined,
		});

		// Generate explanation using GPT-5 model
		const { text } = await generateText({
			model: openai("gpt-5"),
			system: systemPrompt,
			prompt: `
File: ${filePath}

Ruby Code:
\`\`\`ruby
${fileContent}
\`\`\`
`,
		});

		return text;
	} catch (error) {
		// Log the error but return a descriptive error message instead of throwing
		// This allows the CLI to continue processing other files
		console.error(`Error generating explanation for ${filePath}:`, error);
		return `Error generating explanation: ${error instanceof Error ? error.message : "Unknown error"}`;
	}
}

/**
 * Generates a commented Ruby file, preserving behavior while adding inline and block comments
 * for developers new to Ruby.
 */
async function generateCommentedRuby(
	filePath: string,
	fileContent: string,
): Promise<string> {
	const systemPrompt = `You are a senior Ruby on Rails engineer and teacher. Rewrite the provided Ruby file by adding copious explanatory comments for a developer who is new to Ruby but expert in C# (ASP.NET Core Web API) and TypeScript (React/Next.js).

Always follow these rules:
- Only use code inside the Code block delimited by \`\`\`ruby … \`\`\`. Ignore any content outside the delimiters.
- Preserve exact runtime behavior, APIs, method names, and side effects. DO NOT refactor or reorder logic.
- Add both block comments (above definitions) and inline end-of-line comments to explain purpose, Ruby idioms, control flow, and Rails conventions.
- Prefer concise, practical explanations and draw parallels to C#/TypeScript where useful.
- Do not introduce external libraries or dependencies.
- Output only valid Ruby code for the entire file with comments inserted. Do not include markdown or prose outside comments.
- DO NOT WRAP THE OUTPUT IN MARKDOWN CODE BLOCKS FOR RUBY CODE! DO NOT ADD \`\`\`ruby \`\`\` AT THE BEGINNING OR \`\`\` AT THE END!
- If the input is empty, unreadable, or not Ruby, output a single line: # File appears not to be Ruby—skipping.`;

	try {
		const openai = createOpenAI({
			apiKey: process.env.OPENAI_API_KEY,
			baseURL: process.env.OPENAI_BASE_URL,
		});

		const { text } = await generateText({
			model: openai("gpt-5"),
			system: systemPrompt,
			prompt: `
File: ${filePath}

Ruby Code:
\`\`\`ruby
${fileContent}
\`\`\`
`,
		});

		return text;
	} catch (error) {
		console.error(`Error generating commented Ruby for ${filePath}:`, error);
		return `# Error generating commented Ruby: ${error instanceof Error ? error.message : "Unknown error"}`;
	}
}

/**
 * Ensures that the directory for a given file path exists
 *
 * @param filePath - The full path to a file (directory will be extracted)
 * @returns Promise that resolves when directory creation is complete
 *
 * @remarks
 * Creates all necessary parent directories recursively if they don't exist.
 * Logs errors but doesn't throw to allow processing to continue.
 */
async function ensureDirectoryExists(filePath: string): Promise<void> {
	// Extract directory path from the full file path
	const dir = path.dirname(filePath);

	try {
		// Create directory and all parent directories if they don't exist
		await fs.mkdir(dir, { recursive: true });
	} catch (error) {
		// Log error but don't throw - allows processing to continue
		console.error(`Error creating directory ${dir}:`, error);
	}
}

/**
 * Processes a single Ruby file by generating an AI explanation and saving it
 *
 * @param file - FileToProcess object containing file paths and metadata
 * @returns Promise that resolves when processing is complete
 *
 * @remarks
 * The function performs several checks before processing:
 * 1. Skips empty files to avoid unnecessary API calls
 * 2. Skips files that already have explanations to avoid duplicates
 * 3. Handles errors gracefully to allow batch processing to continue
 */
async function processFile(
	file: FileToProcess,
	mode: GenerationMode,
): Promise<void> {
	console.log(`Processing: ${file.relativePath}`);

	// Skip empty files to save API calls and avoid meaningless explanations
	if (await isFileEmpty(file.filePath)) {
		console.log(`  Skipping empty file: ${file.relativePath}`);
		return;
	}

	// Determine output path based on mode
	const outputPath =
		mode === "comment"
			? path.join(DOCS_OUTPUT_DIR, file.relativePath) // mirror .rb path
			: path.join(DOCS_OUTPUT_DIR, `${file.relativePath}.md`);

	// Check if output already exists to avoid regenerating
	try {
		await fs.access(outputPath);
		console.log(`  Output already exists: ${outputPath}`);
		return;
	} catch {
		// File doesn't exist, continue
	}

	try {
		// Read the Ruby file content
		const fileContent = await fs.readFile(file.filePath, "utf-8");

		// Generate AI-powered content
		console.log(
			`  Generating ${mode === "comment" ? "commented Ruby" : "explanation"}...`,
		);
		const output =
			mode === "comment"
				? await generateCommentedRuby(file.relativePath, fileContent)
				: await generateExplanation(file.relativePath, fileContent);

		// Ensure the output directory structure exists
		await ensureDirectoryExists(outputPath);

		// Write the result to the mirrored location in docs folder
		await fs.writeFile(outputPath, output, "utf-8");
		console.log(`  ✓ Saved: ${outputPath}`);
	} catch (error) {
		// Log error but continue processing other files
		console.error(`  ✗ Error processing ${file.relativePath}:`, error);
	}
}

/**
 * Main entry point for the emerald CLI application
 *
 * Orchestrates the entire process of scanning Ruby files and generating explanations:
 * 1. Validates environment setup (API keys, directories)
 * 2. Scans for Ruby files in the target directory
 * 3. Processes each file to generate AI explanations
 * 4. Implements rate limiting to respect API constraints
 *
 * @returns Promise that resolves when all processing is complete
 *
 * @throws Process exits with code 1 if critical requirements are not met
 */
async function main(): Promise<void> {
	// Display application header
	console.log("🤖 emerald - Ruby Code Explainer");
	console.log("================================");

	// Determine generation mode from CLI args
	let mode: GenerationMode = "markdown";
	for (const arg of process.argv.slice(2)) {
		if (arg === "--mode=comment" || arg === "--comment") {
			mode = "comment";
		}
	}
	console.log(`Mode: ${mode}`);

	// Validate that OpenAI API key is configured
	if (!process.env.OPENAI_API_KEY) {
		console.error("❌ OPENAI_API_KEY environment variable is not set");
		console.error(
			"Please set your OpenAI API key in the .env file or environment variables",
		);
		process.exit(1);
	}

	// Validate that the source directory exists
	try {
		await fs.access(DYNAMIC_PRICING_DIR);
	} catch {
		console.error(`❌ Directory ${DYNAMIC_PRICING_DIR} not found`);
		process.exit(1);
	}

	console.log(`📁 Scanning ${DYNAMIC_PRICING_DIR} for Ruby files...`);

	// Ensure the output directory structure exists
	// Using a dummy file path to create the base directory
	await ensureDirectoryExists(path.join(DOCS_OUTPUT_DIR, "dummy"));

	// Recursively find all Ruby files in the source directory
	const rubyFiles = await getAllRubyFiles(DYNAMIC_PRICING_DIR);

	// Handle case where no Ruby files are found
	if (rubyFiles.length === 0) {
		console.log("No Ruby files found");
		return;
	}

	console.log(`📋 Found ${rubyFiles.length} Ruby files to process`);
	console.log("");

	// Process each file sequentially to avoid overwhelming the API
	for (const file of rubyFiles) {
		await processFile(file, mode);

		// Small delay between requests to respect API rate limits
		// 100ms delay allows for ~10 requests per second
		await new Promise((resolve) => setTimeout(resolve, 100));
	}

	console.log("");
	console.log("✅ Processing complete!");
}

/**
 * Application entry point
 * Executes the main function and handles any unhandled errors
 */
main().catch(console.error);
