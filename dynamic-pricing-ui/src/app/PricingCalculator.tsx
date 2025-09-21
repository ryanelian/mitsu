"use client";

import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { HOTELS, type Hotel } from "./const/HOTELS";
import { PERIODS, type Period } from "./const/PERIODS";
import { ROOMS, type Room } from "./const/ROOMS";
import { AccessibleSelect } from "./lib/AccessibleSelect";
import { isValidationError } from "./lib/errors";
import { GenericErrorMessage } from "./lib/GenericErrorMessage";
import { LoadingIndicator } from "./lib/LoadingIndicator";
import { ValidationErrorMessage } from "./lib/ValidationErrorMessage";
import { PricingResult } from "./PricingResult";
import { pricingQueryOptions } from "./queries/pricingQueryOptions";

/**
 * Interactive pricing calculator component that allows users to select different parameters
 * and get real-time pricing quotes from the backend API
 * @returns JSX element containing form controls and pricing results display
 */
export function PricingCalculator() {
	// Initialize form state with default values that match server-side prefetched data
	// This ensures consistency between server and client rendering
	const [selectedPeriod, setSelectedPeriod] = useState<Period>("Summer");
	const [selectedHotel, setSelectedHotel] = useState<Hotel>(
		"FloatingPointResort",
	);
	const [selectedRoom, setSelectedRoom] = useState<Room>("SingletonRoom");

	// Execute pricing query with current selections, automatically refreshing when parameters change
	// The query key includes all parameters to ensure proper caching and invalidation
	const {
		data: pricingData,
		isLoading,
		error,
		dataUpdatedAt,
	} = useQuery(
		pricingQueryOptions(selectedPeriod, selectedHotel, selectedRoom),
	);

	return (
		<div className="w-md mx-auto bg-white rounded-lg shadow-md p-6">
			<h1 className="text-2xl font-bold text-gray-900 mb-6 text-center">
				Pricing Calculator
			</h1>

			<div className="space-y-1">
				{/* Form controls for selecting pricing parameters */}
				{/* Each selector updates its respective state, triggering a new query automatically */}
				<AccessibleSelect
					label="Period"
					value={selectedPeriod}
					onChange={(value) => setSelectedPeriod(value as Period)}
					options={PERIODS}
				/>

				<AccessibleSelect
					label="Hotel"
					value={selectedHotel}
					onChange={(value) => setSelectedHotel(value as Hotel)}
					options={HOTELS}
				/>

				<AccessibleSelect
					label="Room"
					value={selectedRoom}
					onChange={(value) => setSelectedRoom(value as Room)}
					options={ROOMS}
				/>
			</div>

			<div className="mt-6 p-4 bg-gray-50 rounded-md">
				<h2 className="text-lg font-semibold text-gray-800 mb-2">
					Pricing Result
				</h2>

				{/* Show loading state while fetching new pricing data */}
				{/* React Query automatically handles deduplication of identical requests */}
				{isLoading && (
					<div className="flex items-center justify-center py-7">
						<LoadingIndicator />
					</div>
				)}

				{/* Display error messages with different handling for validation vs generic errors */}
				{/* Validation errors show field-specific messages, generic errors show user-friendly messages */}
				{error && (
					<div className="text-red-600">
						{isValidationError(error) ? (
							<ValidationErrorMessage error={error} />
						) : (
							<GenericErrorMessage error={error} />
						)}
					</div>
				)}

				{/* Render pricing results when data is available */}
				{/* Pass all current selections to maintain context in the result display */}
				{pricingData && (
					<PricingResult
						pricingData={pricingData}
						period={selectedPeriod}
						hotel={selectedHotel}
						room={selectedRoom}
						updatedAt={dataUpdatedAt}
					/>
				)}
			</div>
		</div>
	);
}
