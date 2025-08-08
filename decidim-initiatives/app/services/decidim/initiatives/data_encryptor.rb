# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service to encrypt and decrypt metadata
    class DataEncryptor
      attr_reader :secret

      def initialize(args = {})
        @secret = args.fetch(:secret) || "default"
        @key = ActiveSupport::KeyGenerator.new(secret, hash_digest_class: OpenSSL::Digest::SHA1).generate_key(
          Rails.application.secret_key_base, ActiveSupport::MessageEncryptor.key_len
        )
        @encryptor = ActiveSupport::MessageEncryptor.new(@key)
      end

      def encrypt(data)
        @encryptor.encrypt_and_sign(data)
      end

      def decrypt(encrypted_data)
        @encryptor.decrypt_and_verify(encrypted_data)
      end
    end
  end
end
