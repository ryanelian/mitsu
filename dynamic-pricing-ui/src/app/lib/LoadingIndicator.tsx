"use client";

/**
 * Loading indicator component that displays a spinning animation with loading text
 * This component provides visual feedback during async operations like API requests
 * Uses a standard spinner SVG with proper accessibility attributes for screen readers
 * @returns JSX element containing an animated loading spinner with descriptive text
 */
export function LoadingIndicator() {
	return (
		<div className="flex items-center">
			{/* Animated SVG spinner using Tailwind CSS classes for rotation */}
			{/* Heroicons-style spinner with proper ARIA labels for accessibility */}
			<svg
				aria-label="Loading"
				role="img"
				className="mr-3 -ml-1 size-6 animate-spin text-gray-500"
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
			>
				{/* Background circle that provides the loading track */}
				{/* Opacity makes it subtle while still visible */}
				<circle
					className="opacity-25"
					cx="12"
					cy="12"
					r="10"
					stroke="currentColor"
					strokeWidth="4"
				></circle>
				{/* Animated segment that creates the spinning effect */}
				{/* Higher opacity makes the moving part more prominent */}
				<path
					className="opacity-75"
					fill="currentColor"
					d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
				></path>
			</svg>
			{/* Descriptive text for screen readers and visual users */}
			{/* Provides context about the loading state */}
			<span className="text-gray-700">Loading...</span>
		</div>
	);
}
