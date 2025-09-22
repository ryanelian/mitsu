import { z } from "zod";
import { NextEnv } from "./NextEnv";

/**
 * Secret environment variables schema.
 * MUST NOT be exposed to the client side.
 */
export const secretEnvSchema = z.object({
	API_URL: z.url(),
});

/**
 * Public environment variables schema.
 * Can be safely exposed to the client side.
 */
export const publicEnvSchema = z.object({
	SENTRY_DSN: z.string().optional(),
});

/**
 * Gets all runtime environment variables. Can only be called on the server side.
 * @returns Both server and client environment variables
 */
export const env = new NextEnv(secretEnvSchema, publicEnvSchema);
