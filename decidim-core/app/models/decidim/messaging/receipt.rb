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

      # `inverse_of` is deliberately not declared here, for the same reason as in `Message#sender`: a
      # receipt built through `Message#envelope_for` would be added to the recipient's `receipts`
      # collection and saved through the user, which changes the autosave order for the message and its
      # conversation. The reciprocal `has_many :receipts` on `Decidim::User` is the side that declares
      # `inverse_of`.
      belongs_to :recipient, foreign_key: "decidim_recipient_id", class_name: "Decidim::User"
      belongs_to :message, foreign_key: "decidim_message_id", class_name: "Decidim::Messaging::Message", inverse_of: :receipts

      scope :recipient, ->(recipient) { where(recipient:) }
      scope :unread_by, ->(user) { recipient(user).unread }
      scope :unread, -> { where(read_at: nil) }

      # rubocop:disable-next Rails/SkipsModelValidations
      def self.mark_as_read(user)
        recipient(user).update_all(read_at: Time.current)
      end

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
