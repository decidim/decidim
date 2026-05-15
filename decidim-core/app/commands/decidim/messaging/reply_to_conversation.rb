# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a conversation
    class ReplyToConversation < Decidim::Command
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
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        if form.invalid?
          message.valid?
          return broadcast(:invalid, message.errors.full_messages)
        end

        if message.save
          notify_interlocutors

          broadcast(:ok, message)
        else
          broadcast(:invalid, message.errors.full_messages)
        end
      end

      private

      def sender
        form.context.sender
      end

      def message
        @message ||= conversation.add_message(sender:, body: form.body, user: form.context.current_user)
      end

      def notify_interlocutors
        @already_notified = [form.context.current_user]

        conversation.interlocutors(sender).each do |recipient|
          notify(recipient) do
            ConversationMailer.new_message(sender, recipient, conversation, message).deliver_later
          end
          Decidim::PushNotificationMessageSender.new.new_message(sender, recipient, conversation, message).deliver
        end
      end

      # in order for a recipient to receive an email it should not have direct-messages disabled
      # if direct-messages are disabled, only send if they follow the sending user
      def notify(recipient)
        return unless conversation.unread_count(recipient) == 1
        return unless recipient.accepts_conversation?(form.context.current_user)

        yield unless @already_notified.include?(recipient)
        @already_notified.push(recipient)
      end

      attr_reader :conversation, :form
    end
  end
end
