# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "decidim/rack_attack_rules"

describe Rack::Attack do
  # The rules are defined in decidim-core/lib/decidim/rack_attack_rules.rb and
  # registered by config/initializers/rack_attack.rb, which only registers the
  # throttles outside the test environment. The specs load them into an isolated
  # configuration, so asserting the rules cannot affect the configuration used by
  # the middleware or by the rest of the suite.
  let(:rules) do
    Rack::Attack::Configuration.new.tap do |configuration|
      Decidim::RackAttackRules.register_blocklists!(configuration)
      Decidim::RackAttackRules.register_throttles!(configuration)
    end
  end

  # The rules only use these request methods, so a Struct is enough to call them.
  # media_type, body and content_length are only read by the JSON body rules, query_string
  # only by the query precedence.
  let(:request_class) do
    Struct.new(:path, :ip, :request_method, :params, :media_type, :body, :query_string, :content_length) do
      def put?
        request_method == :put
      end

      def post?
        request_method == :post
      end

      def patch?
        request_method == :patch
      end
    end
  end

  # Rack::Attack#call normalizes PATH_INFO with Rack::Attack::PathNormalizer before the
  # check blocks run, and in a Rails app that is ActionDispatch::Journey::Router::Utils:
  # it collapses repeated slashes and strips the trailing one, so the blocks see the same
  # path Rails routes. The specs feed the Struct the path as the middleware would pass it.
  def normalized_path(path)
    Rack::Attack::PathNormalizer.normalize_path(path)
  end

  describe "system blocklist" do
    let(:blocklist) { rules.blocklists.fetch("block all access to system") }

    context "when the access list is empty" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return([]) }

      it "does not block /system requests" do
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "does not block non-system requests" do
        request = request_class.new("/users", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end
    end

    context "when the access list contains an exact IP" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["192.168.1.10"]) }

      it "does not block /system requests from an allowed IP" do
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "blocks /system requests from an IP outside the allow-list" do
        request = request_class.new("/system", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "does not block non-system requests even from an IP outside the allow-list" do
        request = request_class.new("/users", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "blocks /system sub-paths from an IP outside the allow-list" do
        requests = %w(/system/admin /system/users).map { |path| request_class.new(path, "10.0.0.1", :get, {}) }
        expect(requests.map { |request| blocklist.block.call(request) }).to all(be_truthy)
      end

      it "blocks the repeated-slash form of a /system path, which Rails routes to the same action" do
        # Rack::Attack normalizes PATH_INFO before the block runs, so "//system/admins/sign_in"
        # reaches it as "/system/admins/sign_in" and the allow-list still applies
        request = request_class.new(normalized_path("//system/admins/sign_in"), "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "blocks a /system request when the app is deployed under a subpath" do
        # Rack::Request#path keeps the mount prefix (SCRIPT_NAME) in front of the engine path,
        # so a request reaching the system engine through "/decidim" is a system request too
        request = request_class.new("/decidim/system/admins/sign_in", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end
    end

    context "when the access list contains a CIDR range" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["192.168.1.0/24"]) }

      it "does not block /system requests from an IP inside the range" do
        request = request_class.new("/system", "192.168.1.50", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "blocks /system requests from an IP outside the range" do
        request = request_class.new("/system", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end
    end

    context "when the access list has multiple entries" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["10.0.0.0/8", "192.168.1.10"]) }

      it "does not block a /system request matching the second entry" do
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "blocks a /system request matching none of the entries" do
        request = request_class.new("/system", "172.16.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end
    end

    # Rack::Attack does not rescue exceptions raised by a check block, so an
    # unreadable address must fail closed instead of raising inside the middleware.
    context "when the request address cannot be read" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["192.168.1.10"]) }

      it "blocks a request without an address" do
        request = request_class.new("/system", nil, :get, {})
        expect { blocklist.block.call(request) }.not_to raise_error
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "blocks a request with a non-address value, such as a spoofed X-Forwarded-For" do
        request = request_class.new("/system", "<script>evil", :get, {})
        expect { blocklist.block.call(request) }.not_to raise_error
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "blocks when a configured entry is not a valid address" do
        allow(Decidim).to receive(:system_accesslist_ips).and_return(["not-an-ip"])
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect { blocklist.block.call(request) }.not_to raise_error
        expect(blocklist.block.call(request)).to be_truthy
      end
    end
  end

  describe "oversized JSON body blocklist" do
    let(:blocklist) { rules.blocklists.fetch("reject oversized JSON bodies on authentication paths") }

    def oversized_body
      padding = "x" * Decidim::RackAttackRules::MAX_JSON_BODY_BYTES
      StringIO.new("{\"user\":{\"email\":\"a@b.c\"},\"padding\":\"#{padding}\"}")
    end

    it "rejects a JSON body larger than the read cap on the authentication paths" do
      body = oversized_body
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", body)
      expect(blocklist.block.call(request)).to be_truthy
      # The stream is put back so the app can still read the body when the request is not
      # rejected
      expect(body.pos).to eq(0)
    end

    it "rejects an oversized body when Content-Length is not available" do
      # Rack does not guarantee CONTENT_LENGTH (a chunked request has none), so the overflow
      # has to be detected from the bounded read itself
      request = request_class.new("/en/users/sign_in", "1.2.3.4", :post, {}, "application/json", oversized_body)
      expect(blocklist.block.call(request)).to be_truthy
    end

    it "rejects the same email from several addresses instead of counting it per address" do
      # The per-email throttle cannot key an oversized body, so these requests are rejected
      # before the action instead of getting one counter per address
      body = oversized_body
      requests = ["1.2.3.4", "5.6.7.8", "9.1.1.1"].map { |ip| request_class.new("/en/users/password.json", ip, :post, {}, "application/json", body) }
      expect(requests.map { |request| blocklist.block.call(request) }).to all(be_truthy)
    end

    it "does not reject a JSON body within the cap" do
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", StringIO.new('{"user":{"email":"a@b.c"}}'))
      expect(blocklist.block.call(request)).to be_falsy
    end

    it "does not reject requests to paths the email throttles do not read" do
      # The rule is scoped to the authentication paths, so a large JSON body sent to the API
      # is not rejected by it
      request = request_class.new("/api/graphql", "1.2.3.4", :post, {}, "application/json", oversized_body)
      expect(blocklist.block.call(request)).to be_falsy
    end

    it "does not reject a large body that is not JSON" do
      request = request_class.new("/en/users/sign_in", "1.2.3.4", :post, {}, "application/x-www-form-urlencoded", oversized_body)
      expect(blocklist.block.call(request)).to be_falsy
    end

    it "does not reject a GET request" do
      request = request_class.new("/en/users/password", "1.2.3.4", :get, {}, "application/json", oversized_body)
      expect(blocklist.block.call(request)).to be_falsy
    end
  end

  describe "requests by ip throttle" do
    let(:throttle) { rules.throttles.fetch("requests by ip") }

    # The limit and the period come from environment variables, so stub them to
    # the documented defaults to keep these assertions independent of the
    # environment the suite runs in.
    before do
      allow(Decidim).to receive(:throttling_max_requests).and_return(100)
      allow(Decidim).to receive(:throttling_period).and_return(1.minute)
    end

    it "has a limit of 100 requests per period" do
      expect(throttle.limit).to eq(100)
    end

    it "has a 1 minute period" do
      expect(throttle.period).to eq(1.minute.to_i)
    end

    it "reads the limit from the Decidim configuration at registration time" do
      allow(Decidim).to receive(:throttling_max_requests).and_return(42)
      expect(rules.throttles.fetch("requests by ip").limit).to eq(42)
    end

    it "reads the period from the Decidim configuration at registration time" do
      allow(Decidim).to receive(:throttling_period).and_return(5.minutes)
      expect(rules.throttles.fetch("requests by ip").period).to eq(5.minutes.to_i)
    end

    it "keys requests by IP" do
      requests = [
        request_class.new("/", "1.2.3.4", :get, {}),
        request_class.new("/other", "1.2.3.4", :get, {}),
        request_class.new("/", "5.6.7.8", :get, {})
      ]
      expect(requests.map { |request| throttle.block.call(request) }).to eq(["1.2.3.4", "1.2.3.4", "5.6.7.8"])
    end
  end

  describe "limit logins per email throttle" do
    let(:throttle) { rules.throttles.fetch("limit logins per email") }

    it "has a limit of 5 requests per minute" do
      expect(throttle.limit).to eq(5)
      expect(throttle.period).to eq(60.seconds.to_i)
    end

    it "returns the email on POST /users/sign_in without a locale segment" do
      # Not routable in Decidim (only a GET redirect exists), but the locale segment is
      # optional in the pattern, so the rule still matches
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns the email on POST /en/users/sign_in" do
      # Decidim routes are locale-prefixed, so this is the path the sign-in form posts to
      request = request_class.new("/en/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns the email when the engine is mounted at a subpath" do
      # The pattern allows any prefix before the path, not only a locale segment
      request = request_class.new("/decidim/en/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns nil on POST /en/users/sign_in/edit" do
      request = request_class.new("/en/users/sign_in/edit", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /users/sign_in without the user param" do
      # A malformed POST must not raise inside the middleware, which has no rescue;
      # the throttle simply does not match
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /users/sign_in with a scalar user param" do
      # e.g. POST /users/sign_in?user=foo, which would raise TypeError inside the middleware
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => "foo" })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on GET /users/sign_in" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :get, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns the email on POST /en/users/sign_in.json" do
      # The format is optional in the routes, so JSON sign-ins are throttled too
      request = request_class.new("/en/users/sign_in.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "counts the trailing-slash form Rails routes with the same counter" do
      # Rack::Attack normalizes PATH_INFO before the block runs, so "/en/users/sign_in/"
      # reaches it as "/en/users/sign_in"
      request = request_class.new(normalized_path("/en/users/sign_in/"), "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "counts the repeated-slash form Rails routes with the same counter" do
      request = request_class.new(normalized_path("//en/users/sign_in"), "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "reads the email from a JSON body, which Rack does not parse into params" do
      request = request_class.new(
        "/en/users/sign_in.json",
        "1.2.3.4",
        :post,
        {},
        "application/json",
        StringIO.new('{"user":{"email":"a@b.c"}}')
      )
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "counts the query string email, which Rails reads with precedence over the body" do
      # ActionDispatch merges the body parameters over the query string, so a request that
      # authenticates one account while the counter key comes from the body leaves the
      # attacked account unthrottled
      request = request_class.new(
        "/en/users/sign_in",
        "1.2.3.4",
        :post,
        { "user" => { "email" => "attacker@b.c" } },
        nil,
        nil,
        "user[email]=victim@b.c"
      )
      expect(throttle.block.call(request)).to eq("victim@b.c")
    end

    # Rack::Attack normalises discriminators with to_s.strip.downcase before
    # building the cache key, so equivalent spellings share one counter.
    it "shares the counter between equivalent spellings through the discriminator normalizer" do
      first = throttle.block.call(request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "A@B.C" } }))
      second = throttle.block.call(request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => " a@b.c " } }))
      expect(Rack::Attack.throttle_discriminator_normalizer.call(first)).to eq(Rack::Attack.throttle_discriminator_normalizer.call(second))
    end

    it "returns nil on POST to other paths" do
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns a different discriminator per email" do
      first = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      second = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "x@y.z" } })
      expect(throttle.block.call(first)).not_to eq(throttle.block.call(second))
    end
  end

  describe "limit password recovery attempts per email throttle" do
    let(:throttle) { rules.throttles.fetch("limit password recovery attempts per email") }

    it "has a limit of 5 requests per minute" do
      expect(throttle.limit).to eq(5)
      expect(throttle.period).to eq(60.seconds.to_i)
    end

    it "returns the email on POST /users/password without a locale segment" do
      # Not routable in Decidim (only a GET redirect exists), but the locale segment is
      # optional in the pattern, so the rule still matches
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns the email on POST /en/users/password" do
      # Decidim routes are locale-prefixed, so this is the path the recovery form posts to
      request = request_class.new("/en/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns nil on POST /users/password without the user param" do
      # A malformed POST must not raise inside the middleware, which has no rescue;
      # the throttle simply does not match
      request = request_class.new("/users/password", "1.2.3.4", :post, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /users/password with a scalar user param" do
      # e.g. POST /users/password?user=foo, which would raise TypeError inside the middleware
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => "foo" })
      expect(throttle.block.call(request)).to be_nil
    end

    it "reads the email from a JSON body, which Rack does not parse into params" do
      # Without the body fallback a JSON recovery request is never counted against
      # the per-email limit, because request.params only holds the query string
      request = request_class.new(
        "/en/users/password.json",
        "1.2.3.4",
        :post,
        {},
        "application/json",
        StringIO.new('{"user":{"email":"a@b.c"}}')
      )
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "reads the email from the JSON media types Rails parses, not only application/json" do
      # Mime::JSON aliases (actionpack/lib/action_dispatch/http/mime_types.rb). Rack parses
      # none of them into params, so all of them need the body fallback
      media_types = ["text/x-json", "application/jsonrequest", "application/problem+json"]
      discriminators = media_types.map do |media_type|
        request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, media_type, StringIO.new('{"user":{"email":"a@b.c"}}'))
        throttle.block.call(request)
      end
      expect(discriminators).to all(eq("a@b.c"))
    end

    it "counts the trailing-slash form Rails routes with the same counter" do
      # Rack::Attack normalizes PATH_INFO before the block runs, so "/en/users/password/"
      # reaches it as "/en/users/password"
      request = request_class.new(normalized_path("/en/users/password/"), "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "rewinds the JSON body so Rails can still parse it" do
      body = StringIO.new('{"user":{"email":"a@b.c"}}')
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", body)
      throttle.block.call(request)
      expect(body.pos).to eq(0)
    end

    it "returns nil for a JSON body that cannot be parsed" do
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", StringIO.new("{not-json"))
      expect { throttle.block.call(request) }.not_to raise_error
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil for an empty JSON body, which reads as nil rather than an empty string" do
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", StringIO.new(""))
      expect { throttle.block.call(request) }.not_to raise_error
      expect(throttle.block.call(request)).to be_nil
    end

    it "counts a JSON body larger than the read cap by IP instead of leaving it uncounted" do
      # The bounded read truncates the JSON, so no email can be extracted while Rails still
      # parses the whole body. A padded body would otherwise reach the action uncounted.
      # The overflow is detected from the read itself rather than from Content-Length, which
      # Rack does not guarantee: a chunked request has no CONTENT_LENGTH at all.
      padding = "x" * Decidim::RackAttackRules::MAX_JSON_BODY_BYTES
      body = StringIO.new("{\"user\":{\"email\":\"a@b.c\"},\"padding\":\"#{padding}\"}")
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", body)
      expect(throttle.block.call(request)).to eq("1.2.3.4")
      expect(body.pos).to eq(0)
    end

    it "counts an oversized body by IP as the fail-closed fallback of the throttle" do
      # The blocklist rejects these requests before they reach the action. When the throttle is
      # evaluated on its own, the counter key is the address because the email cannot be read
      # from a bounded body, so the request is still counted instead of being skipped.
      padding = "x" * Decidim::RackAttackRules::MAX_JSON_BODY_BYTES
      body = StringIO.new("{\"user\":{\"email\":\"a@b.c\"},\"padding\":\"#{padding}\"}")
      first = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", body)
      second = request_class.new("/en/users/password.json", "5.6.7.8", :post, {}, "application/json", body)
      expect(throttle.block.call(first)).to eq("1.2.3.4")
      expect(throttle.block.call(second)).to eq("5.6.7.8")
    end

    it "counts a body read from a stream that cannot be rewound by IP instead of raising" do
      # Rack's SPEC only requires rack.input to respond to gets, each and read, and
      # Rack::Attack does not rescue exceptions raised by a check block. The stream is left
      # unread so Rails can still parse it.
      non_rewindable_body = Class.new do
        def read(maxlen = nil)
          '{"user":{"email":"a@b.c"}}'[0, maxlen]
        end
      end.new
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", non_rewindable_body)
      expect { throttle.block.call(request) }.not_to raise_error
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "returns nil for a JSON body without the resource key" do
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, {}, "application/json", StringIO.new('{"email":"a@b.c"}'))
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on GET /users/password" do
      request = request_class.new("/users/password", "1.2.3.4", :get, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns the email on POST /en/users/password.json" do
      # The format is optional in the routes, so JSON recovery requests are throttled too
      request = request_class.new("/en/users/password.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns nil on POST to other paths" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns a different discriminator per email" do
      first = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      second = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "x@y.z" } })
      expect(throttle.block.call(first)).not_to eq(throttle.block.call(second))
    end
  end

  describe "limit system admin logins per email throttle" do
    let(:throttle) { rules.throttles.fetch("limit system admin logins per email") }

    it "has a limit of 5 requests per minute" do
      expect(throttle.limit).to eq(5)
      expect(throttle.period).to eq(60.seconds.to_i)
    end

    it "returns the email on POST /system/admins/sign_in" do
      # The system engine is mounted outside the locale scope, so this is the real path
      request = request_class.new("/system/admins/sign_in", "1.2.3.4", :post, { "admin" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns the email on POST /system/admins/sign_in.json" do
      request = request_class.new("/system/admins/sign_in.json", "1.2.3.4", :post, { "admin" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
    end

    it "returns nil on GET /system/admins/sign_in" do
      request = request_class.new("/system/admins/sign_in", "1.2.3.4", :get, { "admin" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /system/admins/sign_in without the admin param" do
      request = request_class.new("/system/admins/sign_in", "1.2.3.4", :post, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /system/admins/sign_in with a scalar admin param" do
      request = request_class.new("/system/admins/sign_in", "1.2.3.4", :post, { "admin" => "foo" })
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not use the user param" do
      request = request_class.new("/system/admins/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST to other paths" do
      request = request_class.new("/system/admins", "1.2.3.4", :post, { "admin" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end
  end

  describe "SMS verification throttle" do
    let(:throttle) { rules.throttles.fetch("limit sms verification attempts per ip") }

    it "has a limit of 10 requests per minute" do
      expect(throttle.limit).to eq(10)
      expect(throttle.period).to eq(60.seconds.to_i)
    end

    it "returns the IP on PUT requests to the SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "returns the IP on PATCH requests to the SMS authorization path" do
      # The confirmation is the update action, which Rails routes for both PUT and PATCH, so
      # the PATCH form must reach the limit too
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :patch, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "matches the SMS authorization path when the app is deployed under a subpath" do
      request = request_class.new("/decidim/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "matches the SMS authorization path with different locales" do
      requests = %w(en es ca fr de).map { |locale| request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {}) }
      expect(requests.map { |request| throttle.block.call(request) }).to all(eq("1.2.3.4"))
    end

    it "matches the SMS authorization path with hyphenated locales" do
      requests = %w(es-MX pt-BR zh-CN en-US).map { |locale| request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {}) }
      expect(requests.map { |request| throttle.block.call(request) }).to all(eq("1.2.3.4"))
    end

    it "matches the SMS authorization path with JSON format" do
      request = request_class.new("/en/sms/authorizations.json", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "does not match GET requests to the SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :get, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match POST requests to the SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :post, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match other verification paths" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/sms/authorizations/edit", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "matches requests with query parameters" do
      # Query params are separate from the path, so the rule still matches
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, { code: "123456" })
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end
  end

  describe "postal letter verification throttle" do
    let(:throttle) { rules.throttles.fetch("limit postal letter verification attempts per ip") }

    it "has a limit of 10 requests per minute" do
      expect(throttle.limit).to eq(10)
      expect(throttle.period).to eq(60.seconds.to_i)
    end

    it "returns the IP on PUT requests to the postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "returns the IP on PATCH requests to the postal letter authorization path" do
      # Same as the SMS throttle: Rails routes the confirmation for both PUT and PATCH
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :patch, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "matches the postal letter authorization path with different locales" do
      requests = %w(en es ca fr de).map { |locale| request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {}) }
      expect(requests.map { |request| throttle.block.call(request) }).to all(eq("1.2.3.4"))
    end

    it "matches the postal letter authorization path with hyphenated locales" do
      requests = %w(es-MX pt-BR zh-CN en-US).map { |locale| request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {}) }
      expect(requests.map { |request| throttle.block.call(request) }).to all(eq("1.2.3.4"))
    end

    it "matches the postal letter authorization path with JSON format" do
      request = request_class.new("/en/postal_letter/authorizations.json", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "does not match GET requests to the postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :get, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match POST requests to the postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :post, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match other verification paths" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/postal_letter/authorizations/edit", "1.2.3.4", :put, {})
      expect(throttle.block.call(request)).to be_nil
    end
  end
end
