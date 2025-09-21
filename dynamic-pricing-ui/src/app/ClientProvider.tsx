"use client";

import { QueryClientProvider } from "@tanstack/react-query";
import { getQueryClient } from "./queries/getQueryClient";

/**
 * Props interface for the ClientProviders component
 * Defines the structure for wrapping children with React Query context
 */
interface ClientProvidersProps {
	children: React.ReactNode;
}

/**
 * Root provider component that supplies React Query client to the entire application
 * This component wraps the app with QueryClientProvider to enable server-state management
 * throughout the component tree, allowing components to use React Query hooks
 * @param props - Object containing child components to be wrapped with query context
 * @returns JSX element providing React Query context to child components
 */
export function ClientProviders({ children }: ClientProvidersProps) {
	return (
		<QueryClientProvider client={getQueryClient()}>
			{children}
		</QueryClientProvider>
	);
}
