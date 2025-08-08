# frozen_string_literal: true

module Decidim
  class AttributeEncryptor
    def self.encrypt(string)
      cryptor.encrypt_and_sign(string) if string.present?
    end

    def self.decrypt(string_encrypted)
      return if string_encrypted.blank?

      # `ActiveSupport::MessageEncryptor` expects all values passed to the
      # `#decrypt_and_verify` method to be instances of String as the message
      # verifier calls `#split` on the value objects: https://git.io/JqfOO.
      # If something else is passed, just return the value as is.
      return string_encrypted unless string_encrypted.is_a?(String)

      cryptor.decrypt_and_verify(string_encrypted)
    end

    def self.cryptor
      @cryptor ||= begin
        key = ActiveSupport::KeyGenerator.new("attribute", hash_digest_class: OpenSSL::Digest::SHA1).generate_key(
          Rails.application.secret_key_base, ActiveSupport::MessageEncryptor.key_len
        )
        ActiveSupport::MessageEncryptor.new(key)
      end
    end
  end
end
