import { queryOptions } from "@tanstack/react-query";
import type { Hotel } from "../const/HOTELS";
import type { Period } from "../const/PERIODS";
import type { Room } from "../const/ROOMS";
import { isValidationError } from "../lib/errors";
import { fetchPricing } from "./fetchPricing";

/**
 * Creates React Query options for pricing data fetching
 * This function generates query configuration that automatically handles caching, retries, and error states
 * @param selectedPeriod - The time period for which pricing is requested
 * @param selectedHotel - The hotel identifier for which pricing is requested
 * @param selectedRoom - The room type identifier for which pricing is requested
 * @returns React Query options object configured for pricing data fetching
 */
export const pricingQueryOptions = (
	selectedPeriod: Period,
	selectedHotel: Hotel,
	selectedRoom: Room,
) =>
	queryOptions({
		// Create a unique cache key based on all parameters
		// This ensures that different parameter combinations are cached separately
		// and that changing any parameter invalidates the previous cache entry
		queryKey: ["pricing", selectedPeriod, selectedHotel, selectedRoom],

		// Fetch function that makes the API call and refreshes metrics
		// The refreshMetrics=true parameter ensures health metrics are updated after pricing requests
		queryFn: () =>
			fetchPricing(selectedPeriod, selectedHotel, selectedRoom, true),

		// Retry logic that respects validation errors
		// Validation errors are not retried since they indicate user input issues
		// Generic errors are retried up to 3 times to handle temporary network issues
		retry: (failureCount, error) => {
			return failureCount < 3 && !isValidationError(error);
		},
	});
