# frozen_string_literal: true

module Decidim
  class NewsletterEncryptor < AttributeEncryptor
    # Method to create string encrypt using sent_at time to unsubscribe's user
    def self.sent_at_encrypted(user_id, sent_at)
      cryptor.encrypt("#{user_id}-#{sent_at.to_i}")
    end

    # Method to decrypt sent_at newsletter.
    def self.sent_at_decrypted(string_encrypted)
      cryptor.decrypt(string_encrypted)
    end

    def self.cryptor
      @cryptor ||= new(secret: "sent_at")
    end
  end
end
