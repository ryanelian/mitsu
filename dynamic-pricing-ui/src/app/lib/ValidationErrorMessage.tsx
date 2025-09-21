"use client";
import type { ValidationError } from "./errors";

/**
 * Props interface for the ValidationErrorMessage component
 * Defines the structure for displaying structured validation errors
 */
interface ValidationErrorMessageProps {
	error: ValidationError;
}

/**
 * Component for displaying structured validation errors with field-specific messages
 * This component handles ValidationError objects that contain RFC 7807 Problem Details
 * Provides detailed, field-specific error information to help users fix validation issues
 * @param props - Object containing the validation error to display
 * @returns JSX element containing formatted validation error messages
 */
export function ValidationErrorMessage({ error }: ValidationErrorMessageProps) {
	return (
		<div className="text-red-600">
			{/* Display the main error message/title */}
			{/* This is typically a summary of the validation failure */}
			<p className="font-semibold">{error.message}</p>

			{/* Display field-specific error messages if available */}
			{/* Each field gets its own section with individual error messages */}
			{error.problemDetails.errors && (
				<div className="space-y-1">
					{Object.entries(error.problemDetails.errors).map(
						([field, messages]) => (
							<div key={field} className="text-sm">
								<span className="font-medium capitalize">
									{field}:
								</span>

								<div className="ml-2">
									{/* Display each validation message for the field */}
									{/* Bullet points make individual messages easy to scan */}
									{(messages as string[]).map(
										(message: string, index: number) => (
											<span
												key={`${field}-${message.slice(0, 20)}-${index}`}
												className="block"
											>
												• {message}
											</span>
										),
									)}
								</div>
							</div>
						),
					)}
				</div>
			)}

			{/* Display trace ID for debugging purposes if available */}
			{/* This helps with troubleshooting validation issues in production */}
			{error.problemDetails.traceId && (
				<p className="text-xs text-gray-500 mt-2">
					Trace ID: {error.problemDetails.traceId}
				</p>
			)}
		</div>
	);
}
