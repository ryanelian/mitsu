import { env } from ".";
import { keyOfRuntimeEnv } from "./NextEnv";

/**
 * ClientRuntimeEnv component that injects runtime environment variables into the window object
 *
 * This component creates a script tag that runs before React hydration and makes
 * environment variables available to the client-side code through the window object.
 * The variables are also strongly-typed and can be accessed safely.
 *
 * The component works by:
 * 1. Creating a script tag with JSON-encoded environment variables
 * 2. Injecting it into the DOM before React takes control
 * 3. Making the variables available as window.__RUNTIME_ENV__
 *
 * @param props - Object containing child components
 * @returns JSX element that includes the runtime environment injection script
 */
export function ClientRuntimeEnv() {
	return (
		<script
			// biome-ignore lint/security/noDangerouslySetInnerHtml: Injecting runtime environment variables
			dangerouslySetInnerHTML={{
				__html: `window.${keyOfRuntimeEnv} = ${sanitizeHtmlString(
					JSON.stringify(env.public),
				)};`,
			}}
		/>
	);
}

/**
 * Mapping of unsafe HTML and invalid JavaScript line terminator chars to their
 * Unicode char counterparts which are safe to use in JavaScript strings.
 * @see https://github.com/yahoo/serialize-javascript/blob/main/index.js
 */
const ESCAPED_CHARS = {
	"<": "\\u003C",
	">": "\\u003E",
	"/": "\\u002F",
	"\u2028": "\\u2028",
	"\u2029": "\\u2029",
};

/**
 * Sanitizes a HTML string by replacing < and > with \u003c and \u003e
 * @param htmlString - The HTML string to sanitize
 * @returns The sanitized HTML string
 */
function sanitizeHtmlString(htmlString: string): string {
	let result = htmlString;
	for (const [key, value] of Object.entries(ESCAPED_CHARS)) {
		result = result.replace(key, value);
	}
	return result;
}
