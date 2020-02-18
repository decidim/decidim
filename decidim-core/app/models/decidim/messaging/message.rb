# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a single message in a conversation. A message has a body, and sender
    # and a set of receipts, which correspond to each user that will receive the
    # message, namely, the interlocutors of the sender in the conversation.
    #
    class Message < ApplicationRecord
      include Decidim::FriendlyDates

      belongs_to :sender,
                 foreign_key: :decidim_sender_id,
                 class_name: "Decidim::User"

      belongs_to :conversation,
                 foreign_key: :decidim_conversation_id,
                 touch: true,
                 class_name: "Decidim::Messaging::Conversation"

      has_many :receipts,
               dependent: :destroy,
               foreign_key: :decidim_message_id,
               inverse_of: :message

      validates :sender, :body, presence: true
      validates :body, length: { maximum: 1_000 }

      default_scope { order(created_at: :asc) }

      validate :sender_is_participant

      #
      # Associates receipts for this message for each of the given users,
      # including also a receipt for the remitent (sender) of the message.
      # Receipts are unread by default, except for the sender's receipt.
      #
      # @param recipients [Array<Decidim::User>]
      #
      def envelope_for(recipients)
        receipts.build(recipient: sender, read_at: Time.current)

        recipients.each { |recipient| receipts.build(recipient: recipient) }
      end

      # Public: Returns the message ready to display (it is expected to include HTML)
      def formatted_body
        @formatted_body ||= Decidim::ContentProcessor.render(sanitized_body, "div")
      end

      private

      def sender_is_participant
        errors.add(:sender, :invalid) unless conversation.participants.include?(sender)
      end

      # Private: Returns the comment body sanitized, sanitizing HTML tags
      def sanitized_body
        Rails::Html::WhiteListSanitizer.new.sanitize(
          render_markdown(body),
          scrubber: Decidim::UserInputScrubber.new
        ).try(:html_safe)
      end

      # Private: Initializes the Markdown parser
      def markdown
        @markdown ||= Decidim::Comments::Markdown.new
      end

      # Private: converts the string from markdown to html
      def render_markdown(string)
        markdown.render(string)
      end
    end
  end
end
