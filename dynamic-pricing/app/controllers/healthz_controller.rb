class HealthzController < ApplicationController
    def index
        render json: {
            status: "ok",
            redis: {
                ok: RedisRepository.instance.ping()
            },
            metrics: {
                quota: AppSettings.rate_api_quota,
                rate_api_calls_used: RateApiService.get_api_call_count,
                rate_api_calls_remaining: RateApiService.remaining_quota,
                has_quota_remaining: RateApiService.has_quota_remaining?,
                hit_count: RateApiService.get_hit_count
            }
        }
    end
end
