"use client";

/**
 * Array of available time periods for the pricing calculator
 * These represent different seasonal periods that affect pricing calculations
 * Each period corresponds to different pricing rules and rates in the backend
 * Using `as const` assertion ensures TypeScript treats this as readonly tuple
 * @example
 * const selectedPeriod: Period = "Summer"
 */
export const PERIODS = [
	"Summer",
	"Autumn",
	"Winter",
	"Spring",
	"Invalid",
] as const;

/**
 * TypeScript type representing valid time period identifiers
 * This type is automatically derived from the PERIODS array using typeof
 * Provides type safety when working with period selections throughout the application
 */
export type Period = (typeof PERIODS)[number];
