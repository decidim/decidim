# frozen_string_literal: true

module Decidim
  module Elections
    #
    # Decorator for trustee
    #
    class TrusteePresenter < SimpleDelegator
      def trustee
        __getobj__
      end

      def public_key_thumbprint
        @public_key_thumbprint ||= jwk_thumbprint(JSON.parse(trustee.public_key)) if trustee.public_key.present?
      end

      private

      def jwk_thumbprint(key)
        Base64.urlsafe_encode64(Digest::SHA256.digest(key.slice("e", "kty", "n").to_json), padding: false)
      end
    end
  end
end
