# frozen_string_literal: true

module Decidim
  module Encryptor
    # Method to create string encrypt using sent_at time to unsubscribe's user
    def self.sent_at_encrypted(user_id, sent_at)
      crypt_data.encrypt_and_sign("#{user_id}-#{sent_at.to_i}") # => "NlFBTTMwOUV5UlA1QlNEN2xkY2d6eThYWWh..."
    end

    # Method to decrypt sent_at newsletter.
    def self.sent_at_decrypted(string_encrypted)
      crypt_data.decrypt_and_verify(string_encrypted)
    end

    def self.crypt_data
      key = ActiveSupport::KeyGenerator.new("sent_at").generate_key(
        Rails.application.secrets.secret_key_base, ActiveSupport::MessageEncryptor.key_len
      ) # => "\x89\xE0\x156\xAC..."
      ActiveSupport::MessageEncryptor.new(key) # => #<ActiveSupport::MessageEncryptor ...>
    end
  end
end
