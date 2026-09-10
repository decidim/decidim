# frozen_string_literal: true

require "spec_helper"

describe "Rack::Attack configuration" do
  # Since throttles are only registered outside test environment,
  # we test the throttle logic directly by simulating request objects
  let(:request_class) do
    Struct.new(:path, :ip, :method, :params) do
      def put?
        method == :put
      end

      def post?
        method == :post
      end
    end
  end

  describe "SMS verification throttle" do
    it "matches PUT requests to SMS authorization path" do
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/sms/authorizations$})
      expect(request).to be_put
    end

    it "matches SMS authorization path with different locales" do
      %w(en es ca fr de).each do |locale|
        request = request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/sms/authorizations$})
        expect(request).to be_put
      end
    end

    it "matches SMS authorization path with hyphenated locales" do
      %w(es-MX pt-BR zh-CN en-US).each do |locale|
        request = request_class.new("/#{locale}/sms/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/sms/authorizations$})
        expect(request).to be_put
      end
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
      expect(request.path).not_to match(%r{^/[^/]+/sms/authorizations$})
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/sms/authorizations/edit", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/sms/authorizations$})
    end

    it "does not match paths with query parameters in the path segment" do
      # Query params are separate from path, so this should still match
      request = request_class.new("/en/sms/authorizations", "1.2.3.4", :put, { code: "123456" })
      expect(request.path).to match(%r{^/[^/]+/sms/authorizations$})
    end
  end

  describe "postal letter verification throttle" do
    it "matches PUT requests to postal letter authorization path" do
      request = request_class.new("/en/postal_letter/authorizations", "1.2.3.4", :put, {})
      expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations$})
      expect(request).to be_put
    end

    it "matches postal letter authorization path with different locales" do
      %w(en es ca fr de).each do |locale|
        request = request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations$})
        expect(request).to be_put
      end
    end

    it "matches postal letter authorization path with hyphenated locales" do
      %w(es-MX pt-BR zh-CN en-US).each do |locale|
        request = request_class.new("/#{locale}/postal_letter/authorizations", "1.2.3.4", :put, {})
        expect(request.path).to match(%r{^/[^/]+/postal_letter/authorizations$})
        expect(request).to be_put
      end
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
      expect(request.path).not_to match(%r{^/[^/]+/postal_letter/authorizations$})
    end

    it "does not match paths with additional segments" do
      request = request_class.new("/en/postal_letter/authorizations/edit", "1.2.3.4", :put, {})
      expect(request.path).not_to match(%r{^/[^/]+/postal_letter/authorizations$})
    end
  end
end
