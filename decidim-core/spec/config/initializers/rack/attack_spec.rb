# frozen_string_literal: true

require "spec_helper"
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
  let(:request_class) do
    Struct.new(:path, :ip, :request_method, :params) do
      def put?
        request_method == :put
      end

      def post?
        request_method == :post
      end
    end
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

      it "blocks /system requests from the listed IP" do
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "does not block /system requests from an unlisted IP" do
        request = request_class.new("/system", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "does not block non-system requests even from a listed IP" do
        request = request_class.new("/users", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end

      it "blocks /system sub-paths from the listed IP" do
        requests = %w(/system/admin /system/users).map { |path| request_class.new(path, "192.168.1.10", :get, {}) }
        expect(requests.map { |request| blocklist.block.call(request) }).to all(be_truthy)
      end
    end

    context "when the access list contains a CIDR range" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["192.168.1.0/24"]) }

      it "blocks /system requests from an IP inside the range" do
        request = request_class.new("/system", "192.168.1.50", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end

      it "does not block /system requests from an IP outside the range" do
        request = request_class.new("/system", "10.0.0.1", :get, {})
        expect(blocklist.block.call(request)).to be_falsy
      end
    end

    context "when the access list has multiple entries" do
      before { allow(Decidim).to receive(:system_accesslist_ips).and_return(["10.0.0.0/8", "192.168.1.10"]) }

      it "blocks /system requests matching the second entry" do
        request = request_class.new("/system", "192.168.1.10", :get, {})
        expect(blocklist.block.call(request)).to be_truthy
      end
    end
  end

  describe "requests by ip throttle" do
    let(:throttle) { rules.throttles.fetch("requests by ip") }

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

    it "returns the email on POST /users/sign_in" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to eq("a@b.c")
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

    it "returns nil on POST /users/sign_in.json" do
      # JSON sign-ins are not throttled because of the exact path match
      request = request_class.new("/users/sign_in.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
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

    it "returns the email on POST /users/password" do
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
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

    it "returns nil on GET /users/password" do
      request = request_class.new("/users/password", "1.2.3.4", :get, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "returns nil on POST /users/password.json" do
      request = request_class.new("/users/password.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(throttle.block.call(request)).to be_nil
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
