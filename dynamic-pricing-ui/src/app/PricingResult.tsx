import type { Hotel } from "./const/HOTELS";
import type { Period } from "./const/PERIODS";
import type { Room } from "./const/ROOMS";
import type { PricingResponse } from "./queries/fetchPricing";

/**
 * Props interface for the PricingResult component
 * Defines the structure for displaying pricing information with context
 */
interface PricingResultProps {
	pricingData: PricingResponse;
	period: Period;
	hotel: Hotel;
	room: Room;
	updatedAt: number;
}

/**
 * Component for displaying pricing results with contextual information
 * Shows the calculated rate along with the parameters used to generate it
 * Provides timestamp information to indicate data freshness
 * @param props - Object containing pricing data and context parameters
 * @returns JSX element displaying formatted pricing information
 */
export function PricingResult({
	pricingData,
	period,
	hotel,
	room,
	updatedAt,
}: PricingResultProps) {
	return (
		<div className="text-center">
			{/* Display the pricing rate prominently */}
			{/* Large, bold, green text emphasizes the main result */}
			<p className="text-3xl font-bold text-green-600">
				¥{Number(pricingData.rate).toLocaleString()}
			</p>

			{/* Show the context/parameters used for this pricing calculation */}
			{/* Helps users understand what combination of factors produced this rate */}
			<p className="text-sm text-gray-500 mt-1">
				Rate for {period} at {hotel} - {room}
			</p>

			{/* Display timestamp when data was last updated */}
			{/* Only shown if timestamp is available, helps users understand data freshness */}
			{updatedAt && (
				<p className="text-xs text-gray-400 mt-2">
					Last updated: {new Date(updatedAt).toLocaleString()}
				</p>
			)}
		</div>
	);
}
