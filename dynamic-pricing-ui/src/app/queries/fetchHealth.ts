import { parseErrorResponse } from "../lib/errors";
import { getDynamicPricingProxyApiUrl } from "./getDynamicPricingProxyApiUrl";

/**
 * Interface representing the structure of health check data returned from the API
 * Contains system status information and API usage metrics for monitoring purposes
 */
export interface HealthResponse {
	status: string;
	redis: {
		ok: boolean;
	};
	metrics: {
		quota: number;
		rate_api_calls_used: number;
		rate_api_calls_remaining: number;
		has_quota_remaining: boolean;
		hit_count: number;
	};
}

/**
 * Fetches system health status and metrics from the backend API
 * This endpoint provides real-time information about system connectivity and API usage
 * @returns Promise resolving to health response containing system status and metrics
 * @throws Error if the health check request fails or returns an error response
 */
export async function fetchHealth(): Promise<HealthResponse> {
	// Make API request to the health check endpoint
	// This endpoint is polled regularly to monitor system status
	const response = await fetch(getDynamicPricingProxyApiUrl("/healthz"));

	// Handle HTTP error responses by parsing them into structured errors
	// Health endpoint errors are treated as generic errors since they don't involve validation
	if (!response.ok) {
		await parseErrorResponse(response);
	}

	// Parse and return the JSON response containing health data
	// Response structure is validated by the HealthResponse interface
	return response.json();
}
