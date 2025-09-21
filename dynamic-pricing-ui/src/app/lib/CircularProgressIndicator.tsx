"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";

/**
 * Props interface for the CircularProgressIndicator component
 * Defines the configuration options for the circular progress visualization
 */
interface CircularProgressIndicatorProps {
	dataUpdatedAt: number;
	maxAgeMs?: number;
	size?: number;
	strokeWidth?: number;
	className?: string;
}

/**
 * Circular progress indicator component that shows data freshness over time
 * This component creates an animated circular progress ring that fills up as data gets older
 * Commonly used to indicate when health metrics were last updated
 * @param props - Configuration props for the progress indicator
 * @returns JSX element representing a circular progress indicator
 */
export function CircularProgressIndicator({
	dataUpdatedAt,
	maxAgeMs = 5000,
	size = 40,
	strokeWidth = 6,
	className = "",
}: CircularProgressIndicatorProps) {
	// Current progress percentage (0-100) representing data age
	// Updates continuously to show how "stale" the data is becoming
	const [progress, setProgress] = useState(0);

	// Reference to the interval timer for cleanup
	// Using ref to avoid stale closure issues in the effect cleanup
	const intervalRef = useRef<NodeJS.Timeout | null>(null);

	// Memoized function to calculate current progress based on time elapsed
	// This function is recreated only when dependencies change, optimizing performance
	const updateProgress = useCallback(() => {
		const now = Date.now();
		const age = now - dataUpdatedAt;

		// Calculate progress percentage, clamped between 0 and 100
		// Progress increases as data gets older relative to maxAgeMs
		setProgress(Math.min(age / maxAgeMs, 1) * 100);
	}, [dataUpdatedAt, maxAgeMs]);

	useEffect(() => {
		// Update progress immediately when component mounts or dependencies change
		// This ensures the progress indicator shows current state right away
		updateProgress();

		// Set up interval timer to update progress every 20ms
		// More frequent updates (50fps) provide smooth animation
		intervalRef.current = setInterval(updateProgress, 20);

		// Cleanup function to prevent memory leaks
		// Clears the interval when component unmounts or dependencies change
		return () => {
			if (intervalRef.current) {
				clearInterval(intervalRef.current);
				intervalRef.current = null;
			}
		};
	}, [updateProgress]);

	// Calculate SVG circle properties based on component size and stroke width
	// The radius is calculated to fit within the given size while accounting for stroke width
	const radius = useMemo(() => (size - strokeWidth) / 2, [size, strokeWidth]);

	// Calculate the circumference of the circle for SVG stroke calculations
	// This value is used to determine how much of the circle should be filled
	const circumference = useMemo(() => 2 * Math.PI * radius, [radius]);

	// Calculate stroke-dasharray and stroke-dashoffset based on current progress
	// strokeDasharray defines the total length of the dashed stroke
	// strokeDashoffset controls how much of the dash is visible (progress animation)

	const strokeDashoffset = useMemo(() => circumference * ((100 - progress) / 100), [circumference, progress]);

	return (
		<div
			className={`relative ${className}`}
			style={{ width: size, height: size }}
		>
			<svg
				aria-label="Circular Progress Indicator"
				role="img"
				width={size}
				height={size}
				viewBox={`0 0 ${size} ${size}`}
				style={{ transform: "rotate(-90deg)" }}
			>
				{/* Background circle that serves as the progress track */}
				{/* This provides visual context for the progress ring */}
				<circle
					cx={size / 2}
					cy={size / 2}
					r={radius}
					fill="transparent"
					stroke="#e0e0e0"
					strokeWidth={strokeWidth}
				/>
				{/* Animated progress circle that fills based on data age */}
				{/* Green color indicates fresh/healthy data, fills completely when data is stale */}
				<circle
					cx={size / 2}
					cy={size / 2}
					r={radius}
					fill="transparent"
					stroke="#22c55e"
					strokeWidth={strokeWidth}
					strokeDasharray={circumference}
					strokeDashoffset={strokeDashoffset}
					strokeLinecap="round"
				/>
			</svg>
		</div>
	);
}
