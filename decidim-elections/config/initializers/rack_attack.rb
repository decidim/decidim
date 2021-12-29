# frozen_string_literal: true

if Rails.env.production? || Rails.env.test?
  require "rack/attack"

  # Throttle check census attempts by IP to 6 reqs/minute
  # Return the IP as a discriminator on POST /check_census requests
  Rack::Attack.throttle(
    "limit check census data attempts per request by IP",
    limit: Decidim::Votings.check_census_max_requests,
    period: Decidim::Votings.throttling_period
  ) do |request|
    request.ip if request.path.include?("/check_census") && request.post?
  end
end
