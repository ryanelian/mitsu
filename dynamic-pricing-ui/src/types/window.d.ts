// Strongly-typed window interface for runtime environment variables
// This file extends the global Window interface to include runtime environment variables
// that are injected by the ClientRuntimeEnv component

import type { PublicEnv } from "~/env/schema";

declare global {
	interface Window {
		__RUNTIME_ENV__?: PublicEnv;
	}
}
