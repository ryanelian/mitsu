import type { NextConfig } from "next";

/**
 * Next.js configuration object that defines build and runtime settings
 * This configuration enables Turbopack for faster development builds
 * and sets up the project structure for optimal performance
 */
const nextConfig: NextConfig = {
	/* Configuration options for Next.js application */

	/**
	 * Turbopack configuration for improved development experience
	 * Turbopack provides faster refresh and build times compared to Webpack
	 * The root setting tells Turbopack where to find the project root
	 */
	turbopack: {
		// Set the project root to the current working directory
		// This ensures Turbopack can find all source files and dependencies
		root: process.cwd(),
	},
	/**
	 * Output configuration for Next.js application
	 * This ensures the application can be run as a standalone executable
	 * It helps with deployment and compatibility across different environments
	 */
	output: "standalone",
};

/**
 * Export the Next.js configuration as the default export
 * This configuration will be used by Next.js during both development and production builds
 */
export default nextConfig;
