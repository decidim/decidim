# frozen_string_literal: true

module Decidim
  class AttributeEncryptor
    attr_reader :secret, :hash_digest_class

    def initialize(secret: "attribute", hash_digest_class: OpenSSL::Digest::SHA1)
      @secret = secret
      @hash_digest_class = hash_digest_class
    end

    def encrypt(string)
      return if string.blank?

      encryptor.encrypt_and_sign(string)
    end

    def decrypt(string_encrypted)
      return if string_encrypted.blank?

      # `ActiveSupport::MessageEncryptor` expects all values passed to the
      # `#decrypt_and_verify` method to be instances of String as the message
      # verifier calls `#split` on the value objects: https://git.io/JqfOO.
      # If something else is passed, just return the value as is.
      return string_encrypted unless string_encrypted.is_a?(String)

      encryptor.decrypt_and_verify(string_encrypted)
    end

    def self.encrypt(string)
      cryptor.encrypt(string)
    end

    def self.decrypt(string_encrypted)
      cryptor.decrypt(string_encrypted)
    end

    def self.cryptor
      @cryptor ||= new(secret: "attribute")
    end

    private

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new(key)
    end

    def key
      @key ||= ActiveSupport::KeyGenerator.new(secret, hash_digest_class:).generate_key(
        Rails.application.secret_key_base, ActiveSupport::MessageEncryptor.key_len
      )
    end
  end
end
