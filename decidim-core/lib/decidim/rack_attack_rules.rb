# frozen_string_literal: true

require "ipaddr"

module Decidim
  # The Rack::Attack rules registered by the decidim-core initializer. They live
  # in a module instead of inline in the initializer so the specs can load them
  # in isolation: the initializer only registers the throttles outside the test
  # environment.
  module RackAttackRules
    def self.register_blocklists!(configuration = Rack::Attack.configuration)
      configuration.blocklist("block all access to system") do |request|
        # Requests are blocked if the return value is truthy
        next unless request.path.start_with?("/system")

        Decidim.system_accesslist_ips.any? do |ip_address|
          IPAddr.new(ip_address).include?(IPAddr.new(request.ip))
        end
      end
    end

    def self.register_throttles!(configuration = Rack::Attack.configuration)
      configuration.throttle(
        "requests by ip",
        limit: Decidim.throttling_max_requests,
        period: Decidim.throttling_period,
        &:ip
      )

      # Throttle login attempts for a given email parameter to 5 reqs/minute
      # Return the email as a discriminator on POST /users/sign_in requests
      configuration.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, "/users/sign_in")
      end

      # Throttle password recovery attempts for a given email parameter to 5 reqs/minute
      # Return the email as a discriminator on POST /users/password requests
      configuration.throttle("limit password recovery attempts per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, "/users/password")
      end

      # Throttle SMS verification confirmation attempts per IP to 10 reqs/minute
      configuration.throttle("limit sms verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$}) && request.put?
      end

      # Throttle postal letter verification confirmation attempts per IP to 10 reqs/minute
      configuration.throttle("limit postal letter verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$}) && request.put?
      end
    end

    # The user param can be missing or a scalar (e.g. POST /users/sign_in?user=foo).
    # Rack::Attack does not rescue exceptions raised by a throttle block, so the
    # discriminator must return nil instead of raising inside the middleware.
    def self.email_discriminator(request, path)
      user = request.params["user"]
      user["email"] if user.is_a?(Hash) && request.path == path && request.post?
    end

    private_class_method :email_discriminator
  end
end
