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
      # including also a receipt for the remitent (sender) of the message.
      # Receipts are unread by default, except for the sender's receipt.
      #
      # If the sender is a UserGroup then receipts will be created for its managers
      # a "from" user can be specified to avoid create a receipt for the real user sending the message
      #
      # @param recipients [Array<Decidim::UserBaseEntity>] Users or groups receiving the message
      # @param from [Array<Decidim::User>] the user sending the message in case sender is a group
      #
      def envelope_for(recipients:, from: nil)
        @from = sender.is_a?(User) ? sender : from
        @already_notified = [@from]

        receipts.build(recipient: @from, read_at: Time.current) if @from.is_a?(User)

        all_recipients(recipients).each do |recipient|
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

      # returns all posible recipients from a list of users or groups
      def all_recipients(recipients)
        users = recipients.flat_map do |recipient|
          recipient.is_a?(UserGroup) ? recipient.managers : recipient
        end
        users += sender.managers if sender.is_a?(UserGroup)
        users
      end

      def sender_is_participant
        errors.add(:sender, :invalid) unless conversation.participants.include?(sender)
      end
    end
  end
end
