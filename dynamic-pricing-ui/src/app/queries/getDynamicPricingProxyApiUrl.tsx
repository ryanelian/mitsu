import { env } from "~/env";

/**
 * Generates the appropriate API URL for the dynamic pricing service
 * This function handles the difference between server-side rendering and client-side execution:
 * - Server-side: Uses direct localhost URL to bypass Next.js routing
 * - Client-side: Uses Next.js API route proxy to handle CORS and routing
 * @param path - The API endpoint path (e.g., "/pricing", "/healthz")
 * @returns Complete URL for making API requests to the dynamic pricing service
 */
export function getDynamicPricingProxyApiUrl(path: string) {
	// Server-side rendering: use direct backend URL
	// This bypasses Next.js routing to connect directly to the Rails backend
	// Prevents routing conflicts during server-side data fetching
	if (typeof window === "undefined") {
		// Ensure that there's only one slash between the URL and the path
		const url = env.secret.API_URL.replace(/\/$/, "");
		const normalizedPath = path.replace(/^\//, "");
		return `${url}/${normalizedPath}`;
	}

	// Client-side: use Next.js API route proxy
	// This route handles CORS, authentication, and request forwarding to the backend
	// Provides a clean separation between frontend and backend concerns
	return `/api/dynamic-pricing/${path}`;
}
