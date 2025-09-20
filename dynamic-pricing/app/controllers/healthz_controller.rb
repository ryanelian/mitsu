class HealthzController < ApplicationController
    def index
        redis_ok = false
        begin
            redis_ok = RedisRepository.instance.ping() == "PONG"
        rescue => e
            puts "Error pinging Redis: #{e}"
            redis_ok = false
        end

        render json: {
            status: "ok",
            redis: {
                ok: redis_ok
            }
        }
    end
end
