# frozen_string_literal: true

module Decidim
  module Elections
    module JwkUtils
      JWK_PRIVATE_FIELDS = [:d, :p, :q, :dp, :dq, :qi].freeze

      def self.thumbprint(json)
        Base64.urlsafe_encode64(Digest::SHA256.digest(json.slice(:e, :kty, :n).to_json), padding: false)
      end

      def self.private_key?(json)
        (json.keys & JWK_PRIVATE_FIELDS).any?
      end

      # TODO: remove everything below here when https://github.com/jwt/ruby-jwt/pull/375 is released
      def self.import_private_key(json)
        jwk = JWT::JWK.import(json)
        jwk.keypair.set_key(decode_open_ssl_bn(json[:n]), decode_open_ssl_bn(json[:e]), decode_open_ssl_bn(json[:d]))
        jwk.keypair.set_factors(decode_open_ssl_bn(json[:p]), decode_open_ssl_bn(json[:q]))
        jwk.keypair.set_crt_params(decode_open_ssl_bn(json[:dp]), decode_open_ssl_bn(json[:dq]), decode_open_ssl_bn(json[:qi]))
        jwk
      end

      def self.private_export(jwk)
        raise "Not a private key" unless jwk.private?

        jwk.export.merge(
          d: encode_open_ssl_bn(jwk.keypair.d),
          p: encode_open_ssl_bn(jwk.keypair.p),
          q: encode_open_ssl_bn(jwk.keypair.q),
          dp: encode_open_ssl_bn(jwk.keypair.dmp1),
          dq: encode_open_ssl_bn(jwk.keypair.dmq1),
          qi: encode_open_ssl_bn(jwk.keypair.iqmp)
        )
      end

      def self.encode_open_ssl_bn(key_part)
        ::Base64.urlsafe_encode64(key_part.to_s(2), padding: false)
      end

      def self.decode_open_ssl_bn(jwk_data)
        return nil unless jwk_data

        OpenSSL::BN.new(::Base64.urlsafe_decode64(jwk_data), 2)
      end
    end
  end
end
