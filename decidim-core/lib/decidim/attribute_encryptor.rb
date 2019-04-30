# frozen_string_literal: true

module Decidim
  class AttributeEncryptor
    def self.encrypt(string)
      cryptor.encrypt_and_sign(string) if string.present?
    end

    def self.decrypt(string_encrypted)
      cryptor.decrypt_and_verify(string_encrypted) if string_encrypted.present?
    end

    def self.cryptor
      key = ActiveSupport::KeyGenerator.new("attribute").generate_key(
        Rails.application.secrets.secret_key_base, ActiveSupport::MessageEncryptor.key_len
      )
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
