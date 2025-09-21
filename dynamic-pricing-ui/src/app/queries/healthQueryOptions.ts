import { queryOptions } from "@tanstack/react-query";
import { fetchHealth } from "./fetchHealth";

/**
 * Creates React Query options for health data fetching with automatic polling
 * This function generates query configuration optimized for real-time monitoring
 * @returns React Query options object configured for health data fetching with polling
 */
export const healthQueryOptions = () =>
	queryOptions({
		// Simple cache key since health data doesn't depend on parameters
		// All health requests use the same cache entry, which is appropriate for system-wide status
		queryKey: ["health"],

		// Fetch function that makes the API call to get system health
		// Health data is fetched on-demand and then automatically refreshed
		queryFn: fetchHealth,

		// Automatically refresh health data every 5 seconds for real-time monitoring
		// This ensures the UI always shows current system status without manual refresh
		refetchInterval: 5000, // Refresh every 5 seconds

		// Consider data stale after 1 second to ensure fresh data display
		// This works with refetchInterval to provide responsive real-time updates
		staleTime: 1000, // Consider data stale after 1 second
	});
