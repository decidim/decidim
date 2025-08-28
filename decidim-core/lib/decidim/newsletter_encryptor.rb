# frozen_string_literal: true

module Decidim
  class NewsletterEncryptor
    # Method to create string encrypt using sent_at time to unsubscribe's user
    def self.sent_at_encrypted(user_id, sent_at)
      crypt_data.encrypt_and_sign("#{user_id}-#{sent_at.to_i}")
    end

    # Method to decrypt sent_at newsletter.
    def self.sent_at_decrypted(string_encrypted)
      crypt_data.decrypt_and_verify(string_encrypted)
    end

    def self.crypt_data
      key = ActiveSupport::KeyGenerator.new("sent_at", hash_digest_class: OpenSSL::Digest::SHA1).generate_key(
        Rails.application.secret_key_base, ActiveSupport::MessageEncryptor.key_len
      )
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
