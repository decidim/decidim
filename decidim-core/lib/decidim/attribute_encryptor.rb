# frozen_string_literal: true

module Decidim
  class AttributeEncryptor
    attr_reader :secret, :hash_digest_class, :secret_key_base, :key_len, :is_retry

    def initialize(secret: "attribute", **options)
      @secret = secret
      @hash_digest_class = options.fetch(:hash_digest_class, Rails.application.config.active_support.hash_digest_class)
      @secret_key_base = options.fetch(:secret_key_base, Rails.application.secret_key_base)
      @key_len = options.fetch(:key_len, ActiveSupport::MessageEncryptor.key_len)
      @is_retry = options.fetch(:is_retry, false)
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
    rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
      # Since we have migrated from SHA1 to SHA256, we need to ensure that any encrypted string not migrated is still being decrypted successfully.
      raise e if is_retry

      legacy_encryptor.decrypt(string_encrypted)
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

    def legacy_encryptor
      @legacy_encryptor ||= self.class.new(secret:, hash_digest_class: OpenSSL::Digest::SHA1, is_retry: true)
    end

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new(key)
    end

    def key
      @key ||= key_generator.generate_key(secret_key_base, key_len)
    end

    def key_generator
      @key_generator ||= ActiveSupport::KeyGenerator.new(secret, hash_digest_class:)
    end
  end
end
