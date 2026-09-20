# frozen_string_literal: true

require "spec_helper"

describe Rack::Attack do
  # Since throttles are only registered outside test environment,
  # we test the throttle logic directly by simulating request objects
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

  describe "SMS verification throttle" do
    it "matches PUT requests to SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
      expect(request).to be_put
    end

    it "matches SMS authorization path with different locales" do
      %w(en es ca fr de).each do |locale|
        request = request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
        expect(request).to be_put
      end
    end

    it "matches SMS authorization path with hyphenated locales" do
      %w(es-MX pt-BR zh-CN en-US).each do |locale|
        request = request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
        expect(request).to be_put
      end
    end

    it "matches SMS authorization path with JSON format" do
      request = request_class.new("/en/sms/authorizations.json", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
      expect(request).to be_put
    end

    it "does not match GET requests to SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :get, {})
      expect(request).not_to be_put
    end

    it "does not match POST requests to SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :post, {})
      expect(request).not_to be_put
    end

    it "does not match other verification paths" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/sms/authorizations/edit", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
    end

    it "does not match paths with query parameters in the path segment" do
      # Query params are separate from path, so this should still match
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, { code: "123456" })
      expect(request.path).to match(%r{^/[^/]+/sms/authorizations(?:\.[^/]+)?$})
    end
  end

  describe "postal letter verification throttle" do
    it "matches PUT requests to postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
      expect(request).to be_put
    end

    it "matches postal letter authorization path with different locales" do
      %w(en es ca fr de).each do |locale|
        request = request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
        expect(request).to be_put
      end
    end

    it "matches postal letter authorization path with hyphenated locales" do
      %w(es-MX pt-BR zh-CN en-US).each do |locale|
        request = request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
        expect(request).to be_put
      end
    end

    it "matches postal letter authorization path with JSON format" do
      request = request_class.new("/en/postal_letter/authorizations.json", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
      expect(request).to be_put
    end

    it "does not match GET requests to postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :get, {})
      expect(request).not_to be_put
    end

    it "does not match POST requests to postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :post, {})
      expect(request).not_to be_put
    end

    it "does not match other verification paths" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/postal_letter/authorizations/edit", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/postal_letter/authorizations(?:\.[^/]+)?$})
    end
  end

  describe "system blocklist" do
    let(:blocklist) { Rack::Attack.blocklists["block all access to system"] }

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
        %w(/system/admin /system/users).each do |path|
          request = request_class.new(path, "192.168.1.10", :get, {})
          expect(blocklist.block.call(request)).to be_truthy
        end
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
    # The predicate is `&:ip`, so the meaningful coverage is the
    # configuration the initializer reads at registration time
    it "defaults to 100 max requests" do
      expect(Decidim.throttling_max_requests).to eq(100)
    end

    it "defaults to a 1 minute period" do
      expect(Decidim.throttling_period).to eq(1.minute)
    end

    it "allows overriding the max requests" do
      original = Decidim.throttling_max_requests

      Decidim.throttling_max_requests = 42
      expect(Decidim.throttling_max_requests).to eq(42)
    ensure
      Decidim.throttling_max_requests = original
    end

    it "allows overriding the period" do
      original = Decidim.throttling_period

      Decidim.throttling_period = 5.minutes
      expect(Decidim.throttling_period).to eq(5.minutes)
    ensure
      Decidim.throttling_period = original
    end

    it "keys requests by IP" do
      same_ip = [
        request_class.new("/", "1.2.3.4", :get, {}),
        request_class.new("/other", "1.2.3.4", :get, {})
      ]
      expect(same_ip.map(&:ip).uniq).to eq(["1.2.3.4"])

      different_ips = [
        request_class.new("/", "1.2.3.4", :get, {}),
        request_class.new("/", "5.6.7.8", :get, {})
      ]
      expect(different_ips.map(&:ip).uniq.size).to eq(2)
    end
  end

  describe "limit logins per email throttle" do
    # The throttle is not registered in the test environment, so the
    # discriminator is asserted against the same predicate used in
    # config/initializers/rack_attack.rb
    let(:discriminator) do
      ->(request) { request.params["user"]["email"] if request.path == "/users/sign_in" && request.post? }
    end

    it "returns the email on POST /users/sign_in" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to eq("a@b.c")
    end

    it "raises NoMethodError on POST /users/sign_in without the user param" do
      # Current behavior: request.params["user"] is nil, so the predicate
      # raises instead of returning nil (a malformed POST would 500 in the
      # middleware when throttles are enabled)
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, {})
      expect { discriminator.call(request) }.to raise_error(NoMethodError)
    end

    it "returns nil on GET /users/sign_in" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :get, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end

    it "returns nil on POST /users/sign_in.json" do
      # JSON sign-ins are not throttled because of the exact path match
      request = request_class.new("/users/sign_in.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end

    it "returns nil on POST to other paths" do
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end

    it "returns a different discriminator per email" do
      first = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      second = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "x@y.z" } })
      expect(discriminator.call(first)).not_to eq(discriminator.call(second))
    end
  end

  describe "limit password recovery attempts per email throttle" do
    let(:discriminator) do
      ->(request) { request.params["user"]["email"] if request.path == "/users/password" && request.post? }
    end

    it "returns the email on POST /users/password" do
      request = request_class.new("/users/password", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to eq("a@b.c")
    end

    it "raises NoMethodError on POST /users/password without the user param" do
      # Current behavior: request.params["user"] is nil, so the predicate
      # raises instead of returning nil (a malformed POST would 500 in the
      # middleware when throttles are enabled)
      request = request_class.new("/users/password", "1.2.3.4", :post, {})
      expect { discriminator.call(request) }.to raise_error(NoMethodError)
    end

    it "returns nil on GET /users/password" do
      request = request_class.new("/users/password", "1.2.3.4", :get, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end

    it "returns nil on POST /users/password.json" do
      request = request_class.new("/users/password.json", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end

    it "returns nil on POST /users/sign_in" do
      request = request_class.new("/users/sign_in", "1.2.3.4", :post, { "user" => { "email" => "a@b.c" } })
      expect(discriminator.call(request)).to be_nil
    end
  end
end
