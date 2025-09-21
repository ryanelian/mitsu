"use client";

import { ComprehensiveBurstTester } from "./ComprehensiveBurstTester";
import { RandomizedSustainedTester } from "./RandomizedSustainedTester";

/**
 * Main stress testing component that combines different testing strategies
 * This component serves as a container for various load testing and performance testing tools
 * Provides a unified interface for running different types of stress tests on the pricing API
 * @returns JSX element containing the stress testing interface with multiple test components
 */
export function StressTester() {
	return (
		<div className="w-md mx-auto bg-white rounded-lg shadow-md p-6">
			{/* Main heading for the stress testing section */}
			{/* Identifies this as the stress testing area of the application */}
			<h1 className="text-2xl font-bold text-gray-900 mb-6 text-center">
				Stress Tester
			</h1>

			<div className="space-y-6">
				{/* Include comprehensive burst testing component */}
				{/* This tests the API's ability to handle sudden spikes in traffic */}
				<ComprehensiveBurstTester />

				{/* Include randomized sustained testing component */}
				{/* This tests the API's ability to handle prolonged periods of varying load */}
				<RandomizedSustainedTester />
			</div>
		</div>
	);
}
