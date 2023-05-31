# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Represents the reception of a message by a user. This model is supposed to
    # hold any information about a message that is specific to each user, for
    # example, the read/unread status, the deleted/undeleted status, and so on.
    #
    class Receipt < ApplicationRecord
      self.table_name = "decidim_messaging_receipts"

      belongs_to :recipient, foreign_key: "decidim_recipient_id", class_name: "Decidim::User"
      belongs_to :message, foreign_key: "decidim_message_id", class_name: "Decidim::Messaging::Message"

      scope :recipient, ->(recipient) { where(recipient:) }
      scope :unread_by, ->(user) { recipient(user).unread }
      scope :unread, -> { where(read_at: nil) }

      # rubocop:disable Rails/SkipsModelValidations
      def self.mark_as_read(user)
        recipient(user).update_all(read_at: Time.current)
      end
      # rubocop:enable Rails/SkipsModelValidations

      # The number of messages unread by a user
      #
      # @return [Integer]
      #
      def self.unread_count(user)
        unread_by(user).count
      end
    end
  end
end
