"use client";

import { useState } from "react";
import { HOTELS, type Hotel } from "./const/HOTELS";
import { PERIODS, type Period } from "./const/PERIODS";
import { ROOMS, type Room } from "./const/ROOMS";
import { fetchPricing } from "./queries/fetchPricing";

/**
 * Interface representing the results of a comprehensive burst test execution
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
 * Component for running comprehensive burst testing on the pricing API
 * This test performs concurrent requests across all valid parameter combinations
 * Designed to evaluate system performance under high concurrent load conditions
 * @returns JSX element containing the comprehensive burst test interface
 */
export function ComprehensiveBurstTester() {
	// State management for test execution and results
	const [result, setResult] = useState<TestResult | null>(null);
	const [isRunning, setIsRunning] = useState(false);
	const [progress, setProgress] = useState(0);

	// Filter out invalid options to focus on valid test scenarios
	// Invalid options are used for error testing but not for comprehensive load testing
	const validPeriods = PERIODS.filter((p) => p !== "Invalid") as Period[];
	const validHotels = HOTELS.filter((h) => h !== "Invalid") as Hotel[];
	const validRooms = ROOMS.filter((r) => r !== "Invalid") as Room[];

	/**
	 * Executes the comprehensive burst load test
	 * Creates concurrent requests for all valid parameter combinations repeated 10 times
	 * This tests the system's ability to handle sudden spikes in traffic across all endpoints
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
			// Calculate total expected requests for progress tracking
			// 4 periods × 3 hotels × 3 rooms × 10 iterations = 360 concurrent requests
			const totalRequests =
				validPeriods.length *
				validHotels.length *
				validRooms.length *
				10;
			let createdRequests = 0;

			// Create array to hold all concurrent promises
			// Each promise represents a single API request with different parameters
			const promises: Promise<unknown>[] = [];

			// Generate requests for all parameter combinations, 10 times each
			// This creates a comprehensive test covering every possible valid input
			for (let iteration = 1; iteration <= 10; iteration++) {
				for (const period of validPeriods) {
					for (const hotel of validHotels) {
						for (const room of validRooms) {
							// Create a promise for each parameter combination
							// Each promise handles success/failure counting and progress updates
							promises.push(
								fetchPricing(period, hotel, room)
									.then(() => successCount++)
									.catch((_error) => {
										failedCount++;
										// Skip error message capture to conserve memory during burst testing
									})
									.finally(() => {
										// Update progress as each request completes
										// Provides real-time feedback on test advancement
										createdRequests++;
										setProgress(
											((createdRequests * 1.0) /
												totalRequests) *
												100.0,
										);
									}),
							);
						}
					}
				}
			}

			// Execute all promises concurrently to simulate burst traffic
			// This tests the system's ability to handle high concurrent load
			await Promise.all(promises);
		} catch (error) {
			// Log any unexpected errors that interrupt the test execution
			console.error("Comprehensive test failed:", error);
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
			{/* Test description showing scope and methodology */}
			{/* Explains the comprehensive nature of the burst test */}
			<h2 className="text-lg font-semibold text-gray-800 mb-3">
				Comprehensive Test (Burst)
			</h2>
			<p className="text-sm text-gray-600 mb-3">
				Tests all {validPeriods.length} x {validHotels.length} x{" "}
				{validRooms.length} ={" "}
				{validPeriods.length * validHotels.length * validRooms.length}{" "}
				valid combinations, 10 times each (360 concurrent requests)
			</p>

			{/* Test execution button with loading state */}
			{/* Button is disabled during test execution to prevent multiple concurrent tests */}
			<button
				type="button"
				onClick={runTest}
				disabled={isRunning}
				className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-medium py-2 px-4 rounded-md transition-colors"
			>
				{isRunning ? "Running..." : "Run Comprehensive Test"}
			</button>

			{/* Progress indicator shown during test execution */}
			{/* Visual feedback helps users understand test advancement */}
			{isRunning && (
				<div className="mt-3">
					<div className="w-full bg-gray-200 rounded-full h-2">
						<div
							className="bg-blue-600 h-2 rounded-full"
							style={{ width: `${progress}%` }}
						></div>
					</div>
					<p className="text-sm text-gray-600 mt-1">
						Progress: {progress.toFixed(1)}%
					</p>
				</div>
			)}

			{/* Results display showing test metrics */}
			{/* Only shown after test completion, provides comprehensive performance data */}
			{result && (
				<div className="mt-3 p-3 bg-white rounded border text-gray-900">
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
