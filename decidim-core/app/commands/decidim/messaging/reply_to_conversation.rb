# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a conversation
    class ReplyToConversation < Rectify::Command
      # Public: Initializes the command.
      #
      # conversation - The conversation to be updated.
      # form - A form object with the params.
      def initialize(conversation, form)
        @conversation = conversation
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the message.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if message.save
          notify_interlocutors

          broadcast(:ok, message)
        else
          broadcast(:invalid)
        end
      end

      private

      def sender
        form.current_user
      end

      def message
        @message ||= conversation.add_message(sender: sender, body: form.body)
      end

      def notify_interlocutors
        conversation.interlocutors(sender).each do |recipient|
          if conversation.unread_count(recipient) == 1
            ConversationMailer.new_message(sender, recipient, conversation).deliver_later
          end
        end
      end

      attr_reader :conversation, :form
    end
  end
end
