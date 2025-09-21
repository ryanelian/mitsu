"use client";

/**
 * Array of available room types for the pricing calculator
 * These represent different accommodation types that affect pricing calculations
 * Each room type has different characteristics that influence the final rate
 * Using `as const` assertion ensures TypeScript treats this as readonly tuple
 * @example
 * const selectedRoom: Room = "SingletonRoom"
 */
export const ROOMS = [
	"SingletonRoom",
	"BooleanTwin",
	"RestfulKing",
	"Invalid",
] as const;

/**
 * TypeScript type representing valid room type identifiers
 * This type is automatically derived from the ROOMS array using typeof
 * Provides type safety when working with room selections throughout the application
 */
export type Room = (typeof ROOMS)[number];
