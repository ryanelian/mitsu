import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { ClientProviders } from "./ClientProvider";

/**
 * Configure the Geist Sans font with CSS variable support
 * This font is used for regular text throughout the application
 * The variable allows for dynamic font switching if needed
 */
const geistSans = Geist({
	variable: "--font-geist-sans",
	subsets: ["latin"],
});

/**
 * Configure the Geist Mono font with CSS variable support
 * This monospace font is used for code, numbers, and technical data
 * Provides better readability for pricing information and metrics
 */
const geistMono = Geist_Mono({
	variable: "--font-geist-mono",
	subsets: ["latin"],
});

/**
 * Metadata configuration for the Next.js application
 * These values appear in browser tabs, bookmarks, and social media previews
 * Currently using default Next.js values - should be updated for production
 */
export const metadata: Metadata = {
	title: "Dynamic Pricing UI",
	description: "Dynamic Pricing UI",
};

/**
 * Props interface for the RootLayout component
 * Defines the structure for the root layout wrapper
 */
interface RootLayoutProps {
	children: React.ReactNode;
}

/**
 * Root layout component that wraps the entire application
 * This component provides global styling, fonts, and context providers
 * It serves as the top-level wrapper for all pages in the application
 * @param props - Object containing child components to be rendered
 * @returns JSX element representing the complete HTML document structure
 */
export default function RootLayout({
	children,
}: Readonly<RootLayoutProps>) {
	return (
		<html lang="en">
			<body
				className={`${geistSans.variable} ${geistMono.variable} antialiased`}
			>
				<ClientProviders>{children}</ClientProviders>
			</body>
		</html>
	);
}
