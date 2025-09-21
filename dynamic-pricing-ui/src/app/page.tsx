import { dehydrate, HydrationBoundary } from "@tanstack/react-query";
import { HealthMetrics } from "./HealthMetrics";
import { PricingCalculator } from "./PricingCalculator";
import { getQueryClient } from "./queries/getQueryClient";
import { healthQueryOptions } from "./queries/healthQueryOptions";
import { pricingQueryOptions } from "./queries/pricingQueryOptions";
import { StressTester } from "./StressTester";

/**
 * Main application page component that serves as the entry point for the dynamic pricing UI
 * This component handles server-side data prefetching and client-side hydration for optimal performance
 * @returns JSX element containing the main application layout with all core components
 */
export default async function Home() {
	// Create a singleton query client for managing server-state and caching
	// Server-side: creates a new client for each request
	// Client-side: reuses the existing client to maintain cache across navigation
	const queryClient = getQueryClient();

	// Prefetch pricing data with default values to ensure immediate availability
	// Using specific defaults (Summer, FloatingPointResort, SingletonRoom) provides instant UI feedback
	// while allowing users to change selections later
	await queryClient.prefetchQuery(
		pricingQueryOptions("Summer", "FloatingPointResort", "SingletonRoom"),
	);

	// Prefetch health metrics to show system status immediately on page load
	// This ensures users can see system health without waiting for the first API call
	await queryClient.prefetchQuery(healthQueryOptions());

	return (
		<HydrationBoundary state={dehydrate(queryClient)}>
			<div className="min-h-screen bg-gray-50 py-8 flex gap-4 flex-wrap">
				<PricingCalculator />
				<HealthMetrics />
				<StressTester />
			</div>
		</HydrationBoundary>
	);
}
