import { describe, expect, it } from "vitest";
import {
	isValidationError,
	ProblemDetailsSchema,
	ValidationError,
} from "./errors";

// Test the isValidationError function
describe("isValidationError", () => {
	it("should return true for ValidationError instances", () => {
		const problemDetails = {
			type: "https://example.com/errors/validation",
			title: "Validation failed",
			errors: {
				period: ["Period is required"],
				hotel: ["Hotel must be selected"],
			},
		};

		const error = new ValidationError(problemDetails);
		expect(isValidationError(error)).toBe(true);
	});

	it("should return false for regular Error instances", () => {
		const error = new Error("Regular error");
		expect(isValidationError(error)).toBe(false);
	});

	it("should return false for non-Error values", () => {
		expect(isValidationError("string")).toBe(false);
		expect(isValidationError(42)).toBe(false);
		expect(isValidationError(null)).toBe(false);
	});
});

// Test ProblemDetailsSchema parsing
describe("ProblemDetailsSchema", () => {
	it("should parse valid Problem Details object", () => {
		const validData = {
			type: "https://datatracker.ietf.org/doc/html/rfc7231#section-6.5.1",
			title: "One or more validation errors occurred.",
			instance: "/api/pricing",
			traceId: "trace-123",
			errors: {
				period: ["Period is required", "Period must be valid"],
				hotel: ["Hotel is required"],
			},
		};

		const result = ProblemDetailsSchema.safeParse(validData);
		expect(result.success).toBe(true);
		if (result.success) {
			expect(result.data.title).toBe(
				"One or more validation errors occurred.",
			);
			expect(result.data.errors?.period).toEqual([
				"Period is required",
				"Period must be valid",
			]);
		}
	});

	it("should fail parsing invalid data", () => {
		const invalidData = {
			title: "Error occurred",
			// missing required 'type' field
		};

		const result = ProblemDetailsSchema.safeParse(invalidData);
		expect(result.success).toBe(false);
	});
});
