import { z } from "zod";

// Zod schema for RFC 7807 Problem Details format
// This standard format provides structured error information from APIs
export const ProblemDetailsSchema = z.object({
	type: z.url(),
	title: z.string(),
	instance: z.string().optional(),
	traceId: z.string().optional(),
	errors: z.record(z.string(), z.array(z.string())).optional(),
});

// Infer the TypeScript type from the schema
// This provides type safety for error handling throughout the application
export type ProblemDetails = z.infer<typeof ProblemDetailsSchema>;

// Custom ValidationError class that extends Error
// This specialized error type carries structured problem details for user-friendly error display
export class ValidationError extends Error {
	constructor(
		public readonly problemDetails: ProblemDetails,
		message?: string,
	) {
		super(message || problemDetails.title);
		this.name = "ValidationError";

		// Maintains proper stack trace for where our error was thrown (only available on V8)
		// This helps with debugging by preserving the original call stack
		if (Error.captureStackTrace) {
			Error.captureStackTrace(this, ValidationError);
		}
	}
}

// Type guard function to check if an error is a ValidationError
// This enables type-safe error handling by narrowing the error type
export function isValidationError(error: unknown): error is ValidationError {
	return error instanceof ValidationError;
}

// Function to parse and validate error responses
// This function handles HTTP error responses and converts them into appropriate error types
export async function parseErrorResponse(response: Response): Promise<never> {
	// Extract the raw response text for parsing
	// Using text() instead of json() allows handling of malformed responses
	const responseText = await response.text();

	try {
		// Attempt to parse the response as JSON
		// This may fail if the response is not valid JSON
		const errorData = JSON.parse(responseText);

		// Try to parse as Problem Details format using Zod schema
		// This validates that the error response follows RFC 7807 structure
		const result = ProblemDetailsSchema.safeParse(errorData);

		if (result.success) {
			// If validation succeeds, throw a structured ValidationError
			// This allows components to display field-specific validation messages
			throw new ValidationError(result.data);
		}

		// If not Problem Details format, create a generic error
		// Use the error title if available, otherwise fall back to HTTP status information
		throw new Error(
			errorData.title ||
				`HTTP ${response.status}: ${response.statusText}`,
		);
	} catch (parseError) {
		// Handle cases where JSON parsing fails entirely
		// Re-throw ValidationErrors to preserve structured error information
		if (parseError instanceof ValidationError) {
			throw parseError;
		}

		// For all other parsing failures, throw a generic HTTP error
		// This provides basic error information even when response format is unexpected
		throw new Error(`HTTP ${response.status}: ${response.statusText}`);
	}
}
