import type { Hotel } from "../const/HOTELS";
import type { Period } from "../const/PERIODS";
import type { Room } from "../const/ROOMS";
import { parseErrorResponse } from "../lib/errors";
import { getDynamicPricingProxyApiUrl } from "../lib/getDynamicPricingProxyApiUrl";
import { getQueryClient } from "./getQueryClient";
import { healthQueryOptions } from "./healthQueryOptions";

/**
 * Interface representing the structure of pricing data returned from the API
 * Contains the calculated rate for a specific combination of period, hotel, and room
 */
export interface PricingResponse {
	rate: number;
}

/**
 * Fetches pricing information from the backend API for a given combination of parameters
 * This function handles error parsing and can optionally refresh health metrics
 * @param period - The time period for which pricing is requested (e.g., "Summer", "Winter")
 * @param hotel - The hotel identifier for which pricing is requested
 * @param room - The room type identifier for which pricing is requested
 * @param refreshMetrics - Whether to refresh health metrics after successful pricing fetch
 * @returns Promise resolving to pricing response containing the calculated rate
 * @throws ValidationError if the request parameters are invalid
 * @throws Error if the API request fails or returns an error response
 */
export async function fetchPricing(
	period: Period,
	hotel: Hotel,
	room: Room,
	refreshMetrics: boolean = false,
): Promise<PricingResponse> {
	// Construct URL parameters from the input values
	// Using URLSearchParams ensures proper encoding of special characters
	const params = new URLSearchParams({
		period,
		hotel,
		room,
	});

	// Make API request to the pricing endpoint
	// getDynamicPricingProxyApiUrl handles environment-specific URL construction
	const response = await fetch(
		getDynamicPricingProxyApiUrl(`/pricing?${params}`),
	);

	// Handle HTTP error responses by parsing them into structured errors
	// This function will throw appropriate ValidationError or generic Error objects
	if (!response.ok) {
		await parseErrorResponse(response);
	}

	// Get the singleton query client instance for cache management
	// Using singleton pattern ensures consistent caching behavior across the app
	const queryClient = getQueryClient();

	// If requested, refresh health metrics to update usage statistics
	// This ensures the UI shows current API usage after making a pricing request
	if (refreshMetrics) {
		queryClient.invalidateQueries(healthQueryOptions());
	}

	// Parse and return the JSON response containing pricing data
	// Response structure is validated by the PricingResponse interface
	return response.json();
}
