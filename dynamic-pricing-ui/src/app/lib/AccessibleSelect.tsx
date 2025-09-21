"use client";
import { useId } from "react";

/**
 * Props interface for the AccessibleSelect component
 * Defines the structure for form select inputs with accessibility features
 */
export interface AccessibleSelectProps {
	label: string;
	value: string;
	onChange: (value: string) => void;
	options: readonly string[];
}

/**
 * Accessible select component that follows WCAG guidelines for form controls
 * This component provides proper labeling, keyboard navigation, and screen reader support
 * @param props - The component props including label, value, onChange, and options
 * @returns JSX element representing an accessible select dropdown
 */
export function AccessibleSelect({
	label,
	value,
	onChange,
	options,
}: AccessibleSelectProps) {
	// Generate unique IDs for accessibility attributes
	// These IDs ensure proper linking between label, select, and description elements
	const labelId = useId();
	const selectId = useId();

	return (
		<div className="mb-4">
			<label
				id={labelId}
				htmlFor={selectId}
				className="block text-sm font-bold text-gray-700 mb-1"
			>
				{label}
			</label>
			<select
				id={selectId}
				value={value}
				onChange={(e) => onChange(e.target.value)}
				className="w-full text-gray-700 px-3 py-2 border border-gray-300 rounded-md focus:ring-offset-1 shadow-sm focus:outline-none focus:ring-3 focus:ring-blue-500 transition"
				aria-describedby={`${labelId}-description`}
			>
				<option value="">Unselected</option>
				{options.map((option) => (
					<option key={option} value={option}>
						{option}
					</option>
				))}
			</select>
			<div id={`${labelId}-description`} className="sr-only">
				Choose a {label.toLowerCase()} from the dropdown menu
			</div>
		</div>
	);
}
