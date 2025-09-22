"use client";

import { useQuery } from "@tanstack/react-query";
import { CircularProgressIndicator } from "./lib/CircularProgressIndicator";
import { GenericErrorMessage } from "./lib/GenericErrorMessage";
import { LoadingIndicator } from "./lib/LoadingIndicator";
import { healthQueryOptions } from "./queries/healthQueryOptions";

/**
 * System health and metrics dashboard component that displays real-time system status
 * This component automatically refreshes every 5 seconds to provide live monitoring data
 * @returns JSX element containing system health status and API usage metrics
 */
export function HealthMetrics() {
	// Poll health metrics every 5 seconds to provide real-time system status
	// Merge base query options with polling configuration for automatic updates
	const {
		data: healthData,
		isLoading,
		error,
		dataUpdatedAt,
	} = useQuery({
		...healthQueryOptions(),
		refetchInterval: 5000, // Refresh every 5 seconds for near real-time updates
	});

	return (
		<div className="w-md mx-auto bg-white rounded-lg shadow-md p-6">
			<h1 className="text-2xl font-bold text-gray-900 mb-6 text-center flex items-center justify-center gap-3">
				<span>System Health & Metrics</span>
				{dataUpdatedAt && (
					<CircularProgressIndicator
						dataUpdatedAt={dataUpdatedAt}
						maxAgeMs={5000}
						size={20}
						strokeWidth={4}
					/>
				)}
			</h1>

			<div className="space-y-4">
				{/* Show loading state while initial data is being fetched */}
				{/* Subsequent refreshes happen automatically in the background */}
				{isLoading && (
					<div className="flex items-center justify-center py-7">
						<LoadingIndicator />
					</div>
				)}

				{/* Display error state if health check fails */}
				{/* Generic error handling since health endpoint doesn't return validation-specific errors */}
				{error && (
					<div className="text-red-600">
						<GenericErrorMessage error={error} />
					</div>
				)}

				{healthData && (
					<div className="space-y-4">
						{/* System Status Section - shows overall health and key service connectivity */}
						{/* Color-coded status indicators provide immediate visual feedback */}
						<div className="p-4 bg-gray-50 rounded-md">
							<h2 className="text-lg font-semibold text-gray-800 mb-3">
								System Status
							</h2>
							<div className="space-y-2">
								<div className="flex justify-between items-center">
									<span className="text-gray-600">
										Overall Status:
									</span>
									<span
										className={`px-2 py-1 rounded text-sm font-medium ${
											healthData.status === "ok"
												? "bg-green-100 text-green-800"
												: "bg-red-100 text-red-800"
										}`}
									>
										{healthData.status}
									</span>
								</div>
								<div className="flex justify-between items-center">
									<span className="text-gray-600">
										Redis:
									</span>
									<span
										className={`px-2 py-1 rounded text-sm font-medium ${
											healthData.redis.ok
												? "bg-green-100 text-green-800"
												: "bg-red-100 text-red-800"
										}`}
									>
										{healthData.redis.ok
											? "Connected"
											: "Disconnected"}
									</span>
								</div>
							</div>
						</div>

						{/* API Metrics Section - displays usage statistics for the rate limiting system */}
						{/* Grid layout provides easy scanning of multiple metrics at once */}
						<div className="p-4 bg-gray-50 rounded-md">
							<h2 className="text-lg font-semibold text-gray-800 mb-3">
								API Metrics
							</h2>
							<div className="grid grid-cols-2 gap-4">
								<div className="text-center">
									<div className="text-2xl font-bold text-blue-600">
										{healthData.metrics.quota}
									</div>
									<div className="text-sm text-gray-500">
										Total Quota
									</div>
								</div>
								<div className="text-center">
									<div className="text-2xl font-bold text-orange-600">
										{healthData.metrics.rate_api_calls_used}
									</div>
									<div className="text-sm text-gray-500">
										Used
									</div>
								</div>
								<div className="text-center">
									<div className="text-2xl font-bold text-green-600">
										{
											healthData.metrics
												.rate_api_calls_remaining
										}
									</div>
									<div className="text-sm text-gray-500">
										Remaining
									</div>
								</div>
								<div className="text-center">
									<div className="text-2xl font-bold text-purple-600">
										{Number(
											healthData.metrics.hit_count,
										).toLocaleString()}
									</div>
									<div className="text-sm text-gray-500">
										Hit Count
									</div>
								</div>
							</div>
							{/* Summary indicator showing overall quota status */}
							{/* Provides immediate visual cue about system capacity */}
							<div className="mt-4 flex justify-center">
								<span
									className={`px-3 py-1 rounded-full text-sm font-medium ${
										healthData.metrics.has_quota_remaining
											? "bg-green-100 text-green-800"
											: "bg-red-100 text-red-800"
									}`}
								>
									{healthData.metrics.has_quota_remaining
										? "Quota Available"
										: "Quota Exhausted"}
								</span>
							</div>
						</div>

						{/* Timestamp showing when data was last refreshed */}
						{/* Helps users understand data freshness, especially important for polled data */}
						<div className="text-center">
							<p className="text-xs text-gray-400">
								Last updated:{" "}
								{new Date(dataUpdatedAt).toLocaleString()}
							</p>
						</div>
					</div>
				)}
			</div>
		</div>
	);
}
