"use client";
import { useMemo } from "react";

/**
 * Props interface for the GenericErrorMessage component
 * Defines the structure for displaying generic error messages
 */
interface GenericErrorMessageProps {
	error: Error;
}

/**
 * Component for displaying generic error messages in a user-friendly format
 * This component handles any Error object and displays the message with appropriate styling
 * Used as a fallback when more specific error handling isn't available
 * @param props - Object containing the error to display
 * @returns JSX element containing the formatted error message
 */
export function GenericErrorMessage({ error }: GenericErrorMessageProps) {
	// Memoize the error message to avoid unnecessary re-renders
	// This optimization prevents the component from re-rendering when the same error is passed
	const message = useMemo(() => {
		return error.message || "An unknown error occurred";
	}, [error]);

	return (
		<div className="text-red-600">
			{/* Display the error message with bold styling for emphasis */}
			{/* Red color indicates error state, semibold font weight draws attention */}
			<p className="font-semibold">{message}</p>
		</div>
	);
}
