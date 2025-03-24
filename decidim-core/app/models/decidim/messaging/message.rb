# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a single message in a conversation. A message has a body, and sender
    # and a set of receipts, which correspond to each user that will receive the
    # message, namely, the interlocutors of the sender in the conversation.
    #
    class Message < ApplicationRecord
      self.table_name = "decidim_messaging_messages"

      include Decidim::FriendlyDates

      belongs_to :sender,
                 foreign_key: :decidim_sender_id,
                 class_name: "Decidim::UserBaseEntity"

      belongs_to :conversation,
                 foreign_key: :decidim_conversation_id,
                 touch: true,
                 class_name: "Decidim::Messaging::Conversation"

      has_many :receipts,
               dependent: :destroy,
               foreign_key: :decidim_message_id,
               inverse_of: :message

      validates :body, presence: true, length: { maximum: ->(_message) { Decidim.config.maximum_conversation_message_length } }

      default_scope { order(created_at: :asc) }

      validate :sender_is_participant

      #
      # Associates receipts for this message for each of the given users,
      # including also a receipt for the remittant (sender) of the message.
      # Receipts are unread by default, except for the sender's receipt.
      #
      # @param recipients [Array<Decidim::UserBaseEntity>] Users receiving the message
      # @param from [Array<Decidim::User>] the user sending the message
      #
      def envelope_for(recipients:, from: nil)
        @from = sender.is_a?(User) ? sender : from
        @already_notified = [@from]

        receipts.build(recipient: @from, read_at: Time.current) if @from.is_a?(User)

        recipients.each do |recipient|
          next if @already_notified.include?(recipient)

          receipts.build(recipient:)
          @already_notified.push(recipient)
        end
      end

      # Public: Returns the comment body with links
      def body_with_links
        Decidim::ContentRenderers::LinkRenderer.new(body).render
      end

      private

      def sender_is_participant
        errors.add(:sender, :invalid) unless conversation.participants.include?(sender)
      end
    end
  end
end
