# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a single message in a conversation. A message has a body, and sender
    # and a set of receipts, which correspond to each user that will receive the
    # message, namely, the interlocutors of the sender in the conversation.
    #
    class Message < ApplicationRecord
      belongs_to :sender,
                 foreign_key: :decidim_sender_id,
                 class_name: "Decidim::User"

      belongs_to :conversation,
                 foreign_key: :decidim_conversation_id,
                 class_name: "Decidim::Messaging::Conversation"

      has_many :receipts,
               dependent: :destroy,
               foreign_key: :decidim_message_id,
               inverse_of: :message

      validates :sender, :body, presence: true
      validates :body, length: { maximum: 1_000 }

      validate :sender_is_participant

      #
      # Associates receipts for this message for each of the given users,
      # including also a receipt for the remitent (sender) of the message.
      # Receipts are unread by default, except for the sender's receipt.
      #
      # @param recipients [Array<Decidim::User>]
      #
      def envelope_for(recipients)
        receipts.build(recipient: sender, read_at: Time.zone.now)

        recipients.each { |recipient| receipts.build(recipient: recipient) }
      end

      private

      def sender_is_participant
        errors.add(:sender, :invalid) unless conversation.participants.include?(sender)
      end
    end
  end
end
