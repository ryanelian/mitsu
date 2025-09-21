import { QueryClient } from "@tanstack/react-query";

// Singleton instance for client-side query client
// This ensures consistent caching behavior across the entire application
let singletonQueryClient: QueryClient | null = null;

/**
 * Creates or returns a singleton QueryClient instance for managing server state
 * This function implements different behavior for server-side rendering vs client-side hydration:
 * - Server-side: Creates a new QueryClient for each request (isolated state)
 * - Client-side: Returns a shared singleton instance (persistent cache across navigation)
 * @returns QueryClient instance configured with appropriate defaults for the current environment
 */
export function getQueryClient() {
	// Server-side rendering: always create a new query client
	// This ensures each server request has isolated state and no cache contamination
	// between different users or requests
	if (typeof window === "undefined") {
		return new QueryClient();
	}

	// Client-side: use singleton pattern to maintain cache across navigation
	// This provides better performance by avoiding unnecessary refetches
	// and maintains user state when navigating between pages
	singletonQueryClient ??= new QueryClient({
		defaultOptions: {
			queries: {
				// Default stale time of 30 seconds balances between fresh data and performance
				// This means data is considered fresh for 30 seconds after fetching
				// After that, background refetching may occur depending on other settings
				staleTime: 30 * 1000, // 30 seconds
			},
		},
	});

	// Return the singleton instance for consistent caching behavior
	return singletonQueryClient;
}
