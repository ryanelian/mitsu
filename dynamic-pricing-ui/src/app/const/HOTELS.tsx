"use client";

/**
 * Array of available hotel options for the pricing calculator
 * These represent different hotel properties that affect pricing calculations
 * Using `as const` assertion ensures TypeScript treats this as readonly tuple
 * @example
 * const selectedHotel: Hotel = "FloatingPointResort"
 */
export const HOTELS = [
	"FloatingPointResort",
	"GitawayHotel",
	"RecursionRetreat",
	"Invalid",
] as const;

/**
 * TypeScript type representing valid hotel identifiers
 * This type is automatically derived from the HOTELS array using typeof
 * Provides type safety when working with hotel selections throughout the application
 */
export type Hotel = (typeof HOTELS)[number];
