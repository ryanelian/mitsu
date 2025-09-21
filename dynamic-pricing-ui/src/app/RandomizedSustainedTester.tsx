"use client";

import { useState } from "react";
import { HOTELS, type Hotel } from "./const/HOTELS";
import { PERIODS, type Period } from "./const/PERIODS";
import { ROOMS, type Room } from "./const/ROOMS";
import { fetchPricing } from "./queries/fetchPricing";

/**
 * Interface representing the results of a stress test execution
 * Contains metrics about test performance including success rate, timing, and errors
 */
interface TestResult {
	success: number;
	failed: number;
	totalTime: number;
	averageResponseTime: number;
	errors: string[];
}

/**
 * Component for running sustained randomized load testing on the pricing API
 * This test performs a large number of sequential requests with randomly selected parameters
 * Designed to evaluate system performance under prolonged, realistic load conditions
 * @returns JSX element containing the randomized sustained test interface
 */
export function RandomizedSustainedTester() {
	// State management for test execution and results
	const [result, setResult] = useState<TestResult | null>(null);
	const [isRunning, setIsRunning] = useState(false);
	const [progress, setProgress] = useState(0);

	// Filter out invalid options to ensure realistic test scenarios
	// Invalid options are used for error testing but not for sustained load testing
	const validPeriods = PERIODS.filter((p) => p !== "Invalid") as Period[];
	const validHotels = HOTELS.filter((h) => h !== "Invalid") as Hotel[];
	const validRooms = ROOMS.filter((r) => r !== "Invalid") as Room[];

	/**
	 * Executes the randomized sustained load test
	 * Makes 1 million sequential requests with randomly selected parameters
	 * Tracks success/failure rates and timing metrics for performance analysis
	 */
	const runTest = async () => {
		// Reset state and prepare for test execution
		setIsRunning(true);
		setResult(null);
		setProgress(0);

		// Record start time for performance measurement
		const startTime = Date.now();
		const errors: string[] = [];
		let successCount = 0;
		let failedCount = 0;

		try {
			// Define test scale - 1 million requests for comprehensive testing
			// This large number provides statistically significant performance data
			const totalRequests = 1000000;

			// Execute sequential requests with randomized parameters
			// Sequential execution ensures consistent load without overwhelming the system
			for (let i = 1; i <= totalRequests; i++) {
				// Randomly select valid parameters for each request
				// This simulates realistic usage patterns across different combinations
				const randomPeriod =
					validPeriods[
						Math.floor(Math.random() * validPeriods.length)
					];
				const randomHotel =
					validHotels[Math.floor(Math.random() * validHotels.length)];
				const randomRoom =
					validRooms[Math.floor(Math.random() * validRooms.length)];

				try {
					// Execute pricing request and track success
					// fetchPricing includes refreshMetrics=true to update health metrics
					await fetchPricing(randomPeriod, randomHotel, randomRoom);
					successCount++;
				} catch (_error) {
					failedCount++;
					// Skip error message capture to conserve memory during large test runs
				}

				// Update progress indicator periodically to show test advancement
				// Updating every 1000 requests balances UI responsiveness with performance
				if (i % 1000 === 0) {
					setProgress((i / totalRequests) * 100);
				}
			}
		} catch (error) {
			// Log any unexpected errors that interrupt the test execution
			console.error("Randomized test failed:", error);
		} finally {
			// Calculate final metrics and update component state
			const endTime = Date.now();
			const totalTime = endTime - startTime;
			const averageResponseTime =
				totalTime / (successCount + failedCount);

			// Update results state to display test outcomes
			setResult({
				success: successCount,
				failed: failedCount,
				totalTime,
				averageResponseTime,
				errors,
			});
			setIsRunning(false);
		}
	};

	return (
		<div className="p-4 bg-gray-50 rounded-md">
			{/* Test description and configuration */}
			{/* Explains what this test does and its scale */}
			<h2 className="text-lg font-semibold text-gray-800 mb-3">
				Randomized Test (Sustained)
			</h2>
			<p className="text-sm text-gray-600 mb-3">
				Performs 1 million sequential random requests
			</p>

			{/* Test execution button with loading state */}
			{/* Button is disabled during test execution to prevent multiple concurrent tests */}
			<button
				type="button"
				onClick={runTest}
				disabled={isRunning}
				className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white font-medium py-2 px-4 rounded-md transition-colors"
			>
				{isRunning ? "Running..." : "Run Randomized Test"}
			</button>

			{/* Progress indicator shown during test execution */}
			{/* Visual feedback helps users understand test advancement */}
			{isRunning && (
				<div className="mt-3">
					<div className="w-full bg-gray-200 rounded-full h-2">
						<div
							className="bg-purple-600 h-2 rounded-full"
							style={{ width: `${progress}%` }}
						></div>
					</div>
					<p className="text-sm text-gray-600 mt-1">
						Progress: {progress.toFixed(1)}% (
						{Math.round(
							(progress / 100) * 1000000,
						).toLocaleString()}{" "}
						requests)
					</p>
				</div>
			)}

			{/* Results display showing test metrics */}
			{/* Only shown after test completion, provides comprehensive performance data */}
			{result && (
				<div className="mt-3 p-3 bg-white rounded border text-gray-800">
					<h3 className="font-semibold mb-2">Results:</h3>
					<div className="grid grid-cols-2 gap-2 text-sm">
						{/* Success/failure counts with emoji indicators */}
						{/* Green checkmark for success, red X for failures */}
						<div>✅ Success: {result.success.toLocaleString()}</div>
						<div>❌ Failed: {result.failed.toLocaleString()}</div>
						{/* Timing metrics for performance analysis */}
						{/* Total time in seconds, average response time in milliseconds */}
						<div>
							Total Time: {(result.totalTime / 1000).toFixed(2)}s
						</div>
						<div>
							Avg Response:{" "}
							{result.averageResponseTime.toFixed(2)}ms
						</div>
					</div>
				</div>
			)}
		</div>
	);
}
