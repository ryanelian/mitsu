import { check, sleep } from 'k6';
import http from 'k6/http';

// Test configuration interface
interface TestOptions {
    scenarios: {
        constant_vus: {
            executor: string;
            vus: number;
            duration: string;
            tags: { test_type: string };
        };
    };
}

// Test configuration
export const options: TestOptions = {
    scenarios: {
        constant_vus: {
            executor: 'constant-vus',
            // Scenario configuration with X amount of concurrent virtual users
            vus: 100,
            duration: '1m', // Run for 1 minute
            tags: { test_type: 'api_load_test' },
        },
    },
};

// Test configuration
const BASE_URL = 'http://localhost:30702';
const ENDPOINT = '/api/dynamic-pricing/pricing';

// Valid test parameters (excluding "Invalid" options)
const VALID_PERIODS = ['Summer', 'Autumn', 'Winter', 'Spring'];
const VALID_HOTELS = ['FloatingPointResort', 'GitawayHotel', 'RecursionRetreat'];
const VALID_ROOMS = ['SingletonRoom', 'BooleanTwin', 'RestfulKing'];

// Helper function to get random element from array
function getRandomElement<T>(array: T[]): T {
    return array[Math.floor(Math.random() * array.length)];
}

export default function () {
    // Generate random valid parameters for each request
    const randomPeriod = getRandomElement(VALID_PERIODS);
    const randomHotel = getRandomElement(VALID_HOTELS);
    const randomRoom = getRandomElement(VALID_ROOMS);

    // Construct the full URL with randomized query parameters
    const url = `${BASE_URL}${ENDPOINT}?period=${randomPeriod}&hotel=${randomHotel}&room=${randomRoom}`;

    // Make the HTTP request
    const response = http.get(url);

    // Validate the response
    const checkResult = check(response, {
        'status is 200': (r) => r.status === 200,
        'response time < 30s': (r) => r.timings.duration < 30000,
        'response contains pricing data': (r) => {
            if (r.status !== 200) return false;
            if (!r.body) return false;
            // Handle both string and ArrayBuffer response bodies
            if (typeof r.body === 'string') {
                return r.body.length > 0;
            }
            if (r.body instanceof ArrayBuffer) {
                return r.body.byteLength > 0;
            }
            return false;
        },
    });

    // Log failed requests for debugging
    if (!checkResult) {
        console.log(`Failed request: ${response.status} - ${response.body || 'No response body'}`);
    }

    // Add realistic delay between requests to simulate user browsing behavior
    sleep(Math.random() * 3 + 1); // Random sleep between 1-4 seconds
}

// Setup function (runs before the test starts)
export function setup() {
    console.log('Starting k6 load test with randomized parameters...');
    console.log(`Target URL: ${BASE_URL}${ENDPOINT}`);
    console.log(`Valid Periods: ${VALID_PERIODS.join(', ')}`);
    console.log(`Valid Hotels: ${VALID_HOTELS.join(', ')}`);
    console.log(`Valid Rooms: ${VALID_ROOMS.join(', ')}`);
    console.log(`Virtual Users: 100`);
    console.log(`Duration: 1 minute`);
    console.log(`Think Time: 2-5 seconds between requests`);
    console.log('Each request will use randomly selected valid parameters');
}

// Teardown function (runs after the test completes)
export function teardown() {
    console.log('Load test completed.');
}
