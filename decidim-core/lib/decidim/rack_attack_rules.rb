# frozen_string_literal: true

require "ipaddr"
require "json"

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

    # Returned by json_resource when the email cannot be identified from the body:
    # the body is larger than the read cap, or the input stream cannot be put back
    # for Rails. Those requests are counted by IP.
    UNIDENTIFIED_BODY = :unidentified_body

    def self.register_blocklists!(configuration = Rack::Attack.configuration)
      configuration.blocklist("block all access to system") do |request|
        # Requests are blocked if the return value is truthy.
        # PATH_INFO is the path inside the mounted application, without the deployment
        # prefix (SCRIPT_NAME), so a subpath deployment still matches here while a process
        # slug such as "/en/processes/system-change" does not. Rack::Attack#call normalizes
        # PATH_INFO with ActionDispatch::Journey::Router::Utils before the check blocks run,
        # which collapses repeated slashes and strips the trailing one, so "//system/admin"
        # reaches the rule as the path Rails routes ("/system/admin").
        next unless request.path_info.to_s.match?(%r{^/system(/|\z)})

        # DECIDIM_SYSTEM_ACCESSLIST_IPS is an allow-list: when it is configured,
        # only the listed IPs can access the system. An empty list means no
        # restriction. The rule used to block the listed IPs instead of allowing
        # them, which denied exactly the operators the feature is meant to permit.
        Decidim.system_accesslist_ips.any? && !allowed_ip?(request.ip, Decidim.system_accesslist_ips)
      end

      configuration.blocklist("reject oversized JSON bodies on authentication paths") do |request|
        # A body larger than the read cap cannot be parsed here, so the account it targets
        # cannot be identified and the request would reach the action with only the per-IP
        # counter: the same email attacked from several addresses then has one counter per
        # address. A throttle block cannot reject a request and must not buffer an unbounded
        # body, so oversized bodies on these paths are rejected before Rails parses them.
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

      # Throttle login attempts for a given email parameter to 5 reqs/minute
      # Return the email as a discriminator on POST /users/sign_in requests
      configuration.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, SIGN_IN_PATH, "user")
      end

      # Throttle password recovery attempts for a given email parameter to 5 reqs/minute
      # Return the email as a discriminator on POST /users/password requests
      configuration.throttle("limit password recovery attempts per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, PASSWORD_PATH, "user")
      end

      # Throttle system admin login attempts for a given email parameter to 5 reqs/minute
      # The system engine is mounted outside the locale scope, so the path has no locale
      # segment; the optional prefix only covers apps mounted at a subpath. System admins
      # have no Devise lockable module, so this is the only limit on brute force there.
      configuration.throttle("limit system admin logins per email", limit: 5, period: 60.seconds) do |request|
        email_discriminator(request, SYSTEM_ADMIN_SIGN_IN_PATH, "admin")
      end

      # Throttle SMS verification confirmation attempts per IP to 10 reqs/minute
      # The confirmation is the update action of the mounted workflow engine, which Rails
      # routes for both PUT and PATCH (actionpack/lib/action_dispatch/routing/mapper.rb),
      # so matching only PUT left the PATCH form unthrottled.
      configuration.throttle("limit sms verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^(/[^/]+)*/sms/authorizations(?:\.[^/]+)?$}) && (request.put? || request.patch?)
      end

      # Throttle postal letter verification confirmation attempts per IP to 10 reqs/minute
      configuration.throttle("limit postal letter verification attempts per ip", limit: 10, period: 60.seconds) do |request|
        request.ip if request.path.match?(%r{^(/[^/]+)*/postal_letter/authorizations(?:\.[^/]+)?$}) && (request.put? || request.patch?)
      end
    end

    # The resource param can be missing or a scalar (e.g. POST /users/sign_in?user=foo).
    # Rack::Attack does not rescue exceptions raised by a throttle block, so the
    # discriminator must return nil instead of raising inside the middleware.
    def self.email_discriminator(request, path_pattern, param_key)
      return unless request.post? && request.path.match?(path_pattern)

      # ActionDispatch gives the query string precedence over the body
      # (ActionDispatch::Http::Parameters#parameters), while Rack::Request#params merges the
      # query over the body. Use Rails' precedence so the counter key is the email the
      # authentication actually reads; otherwise the target account can be attacked with a
      # different counter per request by keeping it in the query string and varying the body.
      # The parsers agree on the supported combination: decidim-core.gemspec requires
      # rack >= 3.2.4, where a query string is parsed the same way by Rack and by
      # ActionDispatch (Rack 3.1 kept a leading separator space as part of the key).
      resource = query_resource(request, param_key) || body_resource(request, param_key)
      return resource["email"] if resource.is_a?(Hash)

      # Fallback for a body whose email cannot be identified. The blocklist above rejects
      # those requests before they reach the action; this keeps the rule fail closed when the
      # throttle is evaluated on its own. The counter key is then the address, not the email.
      request.ip if resource == UNIDENTIFIED_BODY
    end

    def self.query_resource(request, param_key)
      Rack::Utils.parse_nested_query(request.query_string.to_s)[param_key]
    end

    def self.body_resource(request, param_key)
      # Rack does not parse application/json bodies, so request.params only holds
      # the query string for those requests. Without the body fallback, a JSON
      # sign-in or recovery request is never counted against the per-email limit.
      request.params[param_key] || json_resource(request, param_key)
    end

    def self.json_resource(request, param_key)
      return nil unless json_media_type?(request) && request.body

      # Rack's SPEC does not require rack.input to be rewindable (Rack::Lint checks gets,
      # each and read), and ActionDispatch handles a non-rewindable input without rewinding
      # (actionpack/lib/action_dispatch/http/request.rb, reset_stream). Reading a stream that
      # cannot be put back would leave Rails without a body, so the email cannot be read for
      # those requests.
      return UNIDENTIFIED_BODY unless request.body.respond_to?(:rewind)

      json = read_json_body(request)
      return if json.nil?
      return UNIDENTIFIED_BODY if json.bytesize > MAX_JSON_BODY_BYTES

      parsed = JSON.parse(json)
      parsed[param_key] if parsed.is_a?(Hash)
    rescue JSON::ParserError
      nil
    end

    def self.oversized_json_body?(request)
      # Content-Length is not guaranteed: Rack's SPEC does not require it and a chunked
      # request has no CONTENT_LENGTH at all, so the size is taken from the bounded read
      # itself when the header is missing. The stream is put back so the app can still read
      # the body when the request is not rejected, which is only possible for an input that
      # can be rewound; a stream that cannot be put back is left untouched.
      return request.content_length.to_i > MAX_JSON_BODY_BYTES if request.content_length
      return false unless request.body.respond_to?(:rewind)

      json = read_json_body(request)
      !json.nil? && json.bytesize > MAX_JSON_BODY_BYTES
    end

    def self.json_media_type?(request)
      JSON_MEDIA_TYPES.include?(request.media_type.to_s.downcase)
    end

    # Reads at most the cap plus one byte and puts the stream back for Rails.
    def self.read_json_body(request)
      content = request.body.read(MAX_JSON_BODY_BYTES + 1)
      request.body.rewind
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
