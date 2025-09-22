import type { z } from "zod";

/**
 * The key of the runtime environment variables in the window object
 */
export const keyOfRuntimeEnv = "__RUNTIME_ENV__";

/**
 * Strongly-typed Next.js environment variable manager
 *
 * This class provides a clean interface for accessing environment variables
 * with proper separation between secret (server-only) and public (client-safe) variables.
 *
 * @example
 * ```typescript
 * const nextEnv = new NextEnv(secretSchema, publicEnvSchema);
 * const secret = nextEnv.secret; // Server-side only
 * const publics = nextEnv.public; // Safe for client
 * ```
 */
export class NextEnv<
	TSecret extends z.ZodRawShape,
	TPublic extends z.ZodRawShape,
> {
	/**
	 * The schema for secret environment variables (server-only)
	 */
	private readonly secretSchema: z.ZodObject<TSecret>;

	/**
	 * The schema for public environment variables (client-safe)
	 */
	private readonly publicSchema: z.ZodObject<TPublic>;

	constructor(
		secretSchema: z.ZodObject<TSecret>,
		publicSchema: z.ZodObject<TPublic>,
	) {
		this.secretSchema = secretSchema;
		this.publicSchema = publicSchema;
	}

	/**
	 * Gets the server environment variables.
	 * Can only be called on the server side.
	 *
	 * @returns The server environment variables
	 * @throws Error if called on client side
	 */
	get secret(): z.infer<z.ZodObject<TSecret>> {
		// Client-side check
		if (typeof window !== "undefined") {
			throw new Error(
				"NextEnv.secret can only be called on the server side",
			);
		}

		// Server-side parsing
		return this.secretSchema.parse(process.env);
	}

	/**
	 * Gets the client environment variables.
	 * Can be called from both server and client side.
	 *
	 * @returns The client environment variables
	 */
	get public(): z.infer<z.ZodObject<TPublic>> {
		// Client-side: read from window.__RUNTIME_ENV__
		if (typeof window !== "undefined") {
			return this.publicSchema.parse(window[keyOfRuntimeEnv]);
		}

		// Server-side: read from process.env
		return this.publicSchema.parse(process.env);
	}
}
