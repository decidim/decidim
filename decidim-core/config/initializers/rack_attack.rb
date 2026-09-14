# frozen_string_literal: true

if Rails.env.production? || Rails.env.test?
  require "rack/attack"

  Rails.application.configure do |config|
    config.middleware.use Rack::Attack
  end

  ActiveSupport::Reloader.to_prepare do
    Rack::Attack.blocklist("block all access to system") do |request|
      # Requests are blocked if the return value is truthy
      if request.path.start_with?("/system")
        Decidim.system_accesslist_ips.any? && Decidim.system_accesslist_ips.map { |ip_address| IPAddr.new(ip_address).include?(IPAddr.new(request.ip)) }.any?
      end
    end

    unless Rails.env.test?
      Rack::Attack.throttle(
        "requests by ip",
        limit: Decidim.throttling_max_requests,
        period: Decidim.throttling_period,
        &:ip
      )

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

      # Throttle two-factor settings changes to 10 reqs/minute
      # Return the IP as a discriminator on POST and DELETE two_factor_authentication requests
      Rack::Attack.throttle("limit two-factor settings attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if %w(POST DELETE).include?(request.request_method) && request.path.include?("/two_factor_authentication")
      end
    end
  end
end
