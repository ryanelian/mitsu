import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

/**
 * Next.js middleware function that handles API route proxying to the Rails backend
 * This middleware intercepts requests to /api/dynamic-pricing/* and forwards them to localhost:3000
 * Enables seamless communication between the Next.js frontend and Rails backend during development
 * @param request - The incoming Next.js request object
 * @returns NextResponse object that either rewrites the URL or continues the request
 */
export function middleware(request: NextRequest) {
	// Clone the request URL to modify it safely
	// This preserves the original request while allowing URL transformations
	const url = request.nextUrl.clone();

	// Check if the request is for dynamic pricing API routes
	// These routes need to be proxied to the Rails backend server
	if (url.pathname.startsWith("/api/dynamic-pricing/")) {
		// Rewrite the URL to point to the Rails backend API
		// Changes from Next.js API route to direct Rails server communication
		url.protocol = "http";
		url.host = "localhost:3000";
		url.port = "3000";

		// Remove the Next.js API prefix to get the actual Rails endpoint
		// Converts /api/dynamic-pricing/pricing to /pricing for Rails routing
		url.pathname = url.pathname.replace("/api/dynamic-pricing/", "/");

		// Return the rewritten response that proxies to the Rails backend
		// This enables CORS-free communication during development
		return NextResponse.rewrite(url);
	}

	// For non-API routes (pages, static files, etc.), continue normally
	// No URL rewriting needed for regular Next.js page requests
	return NextResponse.next();
}

/**
 * Middleware configuration that defines which routes this middleware should handle
 * Uses negative lookahead to exclude static files and optimization routes from middleware processing
 * This improves performance by avoiding unnecessary middleware execution for static assets
 */
export const config = {
	matcher: [
		/*
		 * Match all request paths except for the ones starting with:
		 * - _next/static (static files like CSS, JS bundles)
		 * - _next/image (image optimization files)
		 * - favicon.ico (favicon file)
		 */
		"/((?!_next/static|_next/image|favicon.ico).*)",
	],
};
