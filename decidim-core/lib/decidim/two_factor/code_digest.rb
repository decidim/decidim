# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Single place where one-time codes are digested and compared.
    module CodeDigest
      def self.create(plain)
        ::Devise::Encryptor.digest(Decidim::User, plain)
      end

      def self.match?(digest, plain)
        return false if digest.blank? || plain.blank?

        ::Devise::Encryptor.compare(Decidim::User, digest, plain)
      end
    end
  end
end
