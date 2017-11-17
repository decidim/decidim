# frozen_string_literal: true

module Decidim
  module Messaging
    class Receipt < ApplicationRecord
      belongs_to :recipient, foreign_key: "decidim_recipient_id", class_name: "Decidim::User"
      belongs_to :message, foreign_key: "decidim_message_id", class_name: "Decidim::Messaging::Message"

      validates :recipient, :message, presence: true

      scope :recipient, ->(recipient) { where(recipient: recipient) }
      scope :unread_by, ->(user) { recipient(user).unread }
      scope :unread, -> { where(read_at: nil) }

      # rubocop:disable Rails/SkipsModelValidations
      def self.mark_as_read(user)
        recipient(user).update_all(read_at: Time.zone.now)
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
