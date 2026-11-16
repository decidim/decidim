# frozen_string_literal: true

require "ipaddr"
require "json"

module Decidim
  # The Rack::Attack rules registered by the decidim-core initializer. They live
  # in a module instead of inline in the initializer so the specs can load them
  # in isolation: the initializer only registers the throttles outside the test
  # environment.
  module RackAttackRules
    # Rack caps the query it parses at 4 MiB; cap the JSON body read by the
    # throttle block the same way so a large body is not buffered there.
    MAX_JSON_BODY_BYTES = 4 * 1024 * 1024

    def self.register_blocklists!(configuration = Rack::Attack.configuration)
      configuration.blocklist("block all access to system") do |request|
        # Requests are blocked if the return value is truthy
        next unless request.path.start_with?("/system")

        # DECIDIM_SYSTEM_ACCESSLIST_IPS is an allow-list: when it is configured,
        # only the listed IPs can access the system. An empty list means no
        # restriction. The rule used to block the listed IPs instead of allowing
        # them, which denied exactly the operators the feature is meant to permit.
        Decidim.system_accesslist_ips.any? && !allowed_ip?(request.ip, Decidim.system_accesslist_ips)
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
      # The path is matched with a pattern: Decidim routes are locale-prefixed
      # (decidim-core/config/routes.rb) and the format is optional, so an exact
      # string never matches the requests the app actually receives.
      configuration.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, %r{^(/[^/]+)*/users/sign_in(\.[^/]+)?$}, "user")
      end

      # Throttle password recovery attempts for a given email parameter to 5 reqs/minute
      # Return the email as a discriminator on POST /users/password requests
      configuration.throttle("limit password recovery attempts per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, %r{^(/[^/]+)*/users/password(\.[^/]+)?$}, "user")
      end

      # Throttle system admin login attempts for a given email parameter to 5 reqs/minute
      # The system engine is mounted outside the locale scope, so the path has no locale
      # segment; the optional prefix only covers apps mounted at a subpath. System admins
      # have no Devise lockable module, so this is the only limit on brute force there.
      configuration.throttle("limit system admin logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, %r{^(/[^/]+)*/system/admins/sign_in(\.[^/]+)?$}, "admin")
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

    # The resource param can be missing or a scalar (e.g. POST /users/sign_in?user=foo).
    # Rack::Attack does not rescue exceptions raised by a throttle block, so the
    # discriminator must return nil instead of raising inside the middleware.
    def self.email_discriminator(request, path_pattern, param_key)
      return unless request.post? && request.path.match?(path_pattern)

      # Rack does not parse application/json bodies, so request.params only holds
      # the query string for those requests. Without the body fallback, a JSON
      # sign-in or recovery request is never counted against the per-email limit.
      resource = request.params[param_key] || json_resource(request, param_key)
      resource["email"] if resource.is_a?(Hash)
    end

    def self.json_resource(request, param_key)
      return unless request.media_type == "application/json" && request.body

      json = request.body.read(MAX_JSON_BODY_BYTES)
      # Rewind so Rails can still parse the body after the throttle block read it.
      request.body.rewind
      parsed = JSON.parse(json)
      parsed[param_key] if parsed.is_a?(Hash)
    rescue JSON::ParserError
      nil
    end

    def self.allowed_ip?(ip, allowed_ips)
      return false if ip.blank?

      allowed_ips.any? do |ip_address|
        IPAddr.new(ip_address).include?(IPAddr.new(ip))
      rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
        # Fail closed: an address we cannot read is not an allowed one.
        false
      end
    end

    private_class_method :email_discriminator, :json_resource, :allowed_ip?
  end
end
