# frozen_string_literal: true

if Rails.env.production?
  require "rack/attack"

  Rails.application.configure do |config|
    config.middleware.use Rack::Attack
  end

  Rack::Attack.throttle(
    "requests by ip",
    limit: Decidim.throttling_max_requests,
    period: Decidim.throttling_period,
    &:ip
  )

  Rack::Attack.blocklist("block all access to admin") do |request|
    # Requests are blocked if the return value is truthy
    request.path.start_with?("/system") unless Decidim.whitelist_ips.map { |ip_address| IPAddr.new(ip_address).include?(IPAddr.new(request.ip)) }.any?
  end

  # Throttle login attempts for a given email parameter to 6 reqs/minute
  # Return the email as a discriminator on POST /users/sign_in requests
  Rack::Attack.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
    request.params["user"]["email"] if request.path == "/users/sign_in" && request.post?
  end

  # Throttle login attempts for a given email parameter to 6 reqs/minute
  # Return the email as a discriminator on POST /users/sign_in requests
  Rack::Attack.throttle("limit password recovery attempts per email", limit: 5, period: 60.seconds) do |request|
    request.params["user"]["email"] if request.path == "/users/password" && request.post?
  end
end
