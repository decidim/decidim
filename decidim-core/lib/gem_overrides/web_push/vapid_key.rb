# frozen_string_literal: true

require "web-push"

module WebPush
  module Overrides
    module VapidKey
      def self.from_keys(public_key, private_key)
        key = new
        key.set_keys!(public_key, private_key)

        key
      end

      def self.from_pem(pem)
        new(OpenSSL::PKey.read(pem))
      end

      def initialize(pkey = nil)
        @curve = pkey
        @curve = OpenSSL::PKey::EC.generate("prime256v1") if @curve.nil?
      end

      def public_key=(key)
        set_keys!(key, nil)
      end

      def private_key=(key)
        set_keys!(nil, key)
      end

      def to_pem
        curve.to_pem + curve.public_to_pem
      end

      def set_keys!(public_key = nil, private_key = nil)
        public_key = if public_key.nil?
                       curve.public_key
                     else
                       OpenSSL::PKey::EC::Point.new(group, to_big_num(public_key))
                     end

        private_key = if private_key.nil?
                        curve.private_key
                      else
                        to_big_num(private_key)
                      end

        asn1 = OpenSSL::ASN1::Sequence([
                                         OpenSSL::ASN1::Integer.new(1),
                                         # Not properly padded but OpenSSL doesn't mind
                                         OpenSSL::ASN1::OctetString(private_key.to_s(2)),
                                         OpenSSL::ASN1::ObjectId("prime256v1", 0, :EXPLICIT),
                                         OpenSSL::ASN1::BitString(public_key.to_octet_string(:uncompressed), 1, :EXPLICIT)
                                       ])

        der = asn1.to_der

        @curve = OpenSSL::PKey::EC.new(der)
      end
    end
  end
end
if %w(2.1.0).include?(WebPush::VERSION)
  WebPush::VapidKey.prepend(::WebPush::Overrides::VapidKey)
else
  Rails.logger.debug "\n" * 5
  Rails.logger.debug "WebPush has been updated, and the fix for OpenSSL V3 may be already fixed, Therefore the Override has been disabled."
  Rails.logger.debug "Please check: https://github.com/zaru/webpush/pull/106 for additional details"
  Rails.logger.debug "Please check: https://github.com/pushpad/web-push/ repository for bug resolution and changelog"
  Rails.logger.debug "\n" * 5
end
