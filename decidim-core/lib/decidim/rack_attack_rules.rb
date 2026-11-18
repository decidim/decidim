# frozen_string_literal: true

require "ipaddr"
require "json"
require "stringio"

module Decidim
  # The Rack::Attack rules registered by the decidim-core initializer. They live
  # in a module instead of inline in the initializer so the specs can load them
  # in isolation: the initializer only registers the throttles outside the test
  # environment.
  module RackAttackRules
    # Rack caps the query it parses at 4 MiB; cap the JSON body read by the rules
    # the same way so a large body is not buffered there.
    MAX_JSON_BODY_BYTES = 4 * 1024 * 1024

    # Media types Rails parses as JSON (Mime::JSON and its aliases, see
    # actionpack/lib/action_dispatch/http/mime_types.rb). Rack only parses form and
    # multipart bodies into request.params, so these bodies are read by the rules
    # themselves; matching only "application/json" leaves the aliases uncounted.
    JSON_MEDIA_TYPES = ["application/json", "text/x-json", "application/jsonrequest", "application/problem+json"].freeze

    # Paths whose email throttle reads the request body. Decidim routes are
    # locale-prefixed and the format is optional, so an exact string never matches
    # the requests the app receives; the optional prefix also covers an app deployed
    # under a subpath.
    SIGN_IN_PATH = %r{^(/[^/]+)*/users/sign_in(\.[^/]+)?$}
    PASSWORD_PATH = %r{^(/[^/]+)*/users/password(\.[^/]+)?$}
    SYSTEM_ADMIN_SIGN_IN_PATH = %r{^(/[^/]+)*/system/admins/sign_in(\.[^/]+)?$}
    BODY_READ_PATHS = [SIGN_IN_PATH, PASSWORD_PATH, SYSTEM_ADMIN_SIGN_IN_PATH].freeze

    # Returned by json_resource when the email cannot be identified from the body because
    # it is larger than the read cap. Those requests are counted by IP.
    UNIDENTIFIED_BODY = :unidentified_body

    def self.register_blocklists!(configuration = Rack::Attack.configuration)
      configuration.blocklist("block all access to system") do |request|
        next unless request.path_info.to_s.match?(%r{^/system(/|\z)})

        Decidim.system_accesslist_ips.any? && !allowed_ip?(request.ip, Decidim.system_accesslist_ips)
      end

      configuration.blocklist("reject oversized JSON bodies on authentication paths") do |request|
        next unless request.post? && BODY_READ_PATHS.any? { |pattern| request.path.match?(pattern) }
        next unless json_media_type?(request) && oversized_json_body?(request)

        true
      end
    end

    def self.register_throttles!(configuration = Rack::Attack.configuration)
      configuration.throttle(
        "requests by ip",
        limit: Decidim.throttling_max_requests,
        period: Decidim.throttling_period,
        &:ip
      )

      configuration.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, SIGN_IN_PATH, "user")
      end

      configuration.throttle("limit password recovery attempts per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, PASSWORD_PATH, "user")
      end

      configuration.throttle("limit system admin logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, SYSTEM_ADMIN_SIGN_IN_PATH, "admin")
      end

      configuration.throttle("limit sms verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^(/[^/]+)*/sms/authorizations(?:\.[^/]+)?$}) && (request.put? || request.patch?)
      end

      configuration.throttle("limit postal letter verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^(/[^/]+)*/postal_letter/authorizations(?:\.[^/]+)?$}) && (request.put? || request.patch?)
      end
    end

    def self.email_discriminator(request, path_pattern, param_key)
      return unless request.post? && request.path.match?(path_pattern)

      resource = query_resource(request, param_key) || body_resource(request, param_key)
      return resource["email"] if resource.is_a?(Hash)

      # Fallback for a body whose email cannot be identified.
      request.ip if resource == UNIDENTIFIED_BODY
    end

    def self.query_resource(request, param_key)
      Rack::Utils.parse_nested_query(request.query_string.to_s)[param_key]
    end

    def self.body_resource(request, param_key)
      # Rack does not parse application/json bodies.
      request.params[param_key] || json_resource(request, param_key)
    end

    def self.json_resource(request, param_key)
      return nil unless json_media_type?(request) && request.body

      json = read_json_body(request)
      return if json.nil?
      return UNIDENTIFIED_BODY if json.bytesize > MAX_JSON_BODY_BYTES

      parsed = JSON.parse(json)
      parsed[param_key] if parsed.is_a?(Hash)
    rescue JSON::ParserError
      nil
    end

    def self.oversized_json_body?(request)
      # Rack 3.2 permits rack.input to be absent, and Content-Length is not guaranteed.
      return request.content_length.to_i > MAX_JSON_BODY_BYTES if request.content_length
      return false unless request.body

      json = read_json_body(request)
      !json.nil? && json.bytesize > MAX_JSON_BODY_BYTES
    end

    def self.json_media_type?(request)
      JSON_MEDIA_TYPES.include?(request.media_type.to_s.downcase)
    end

    def self.read_json_body(request)
      content = request.body.read(MAX_JSON_BODY_BYTES + 1)
      if request.body.respond_to?(:rewind)
        request.body.rewind
      else
        request.env["rack.input"] = StringIO.new(content.to_s.dup.force_encoding(Encoding::ASCII_8BIT))
      end
      content
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

    private_class_method :email_discriminator, :query_resource, :body_resource, :json_resource,
                         :oversized_json_body?, :json_media_type?, :read_json_body, :allowed_ip?
  end
end
