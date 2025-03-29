# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a conversation
    class StartConversation < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A conversation form
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the message.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid, form.errors.full_messages) if form.invalid?

        if conversation.save
          notify_interlocutors

          broadcast(:ok, conversation)
        else
          broadcast(:invalid, conversation.errors.full_messages)
        end
      end

      private

      def originator
        form.context.sender
      end

      def conversation
        @conversation ||= Conversation.start(
          originator:,
          interlocutors: form.recipient,
          body: form.body,
          user: form.context.current_user
        )
      end

      def notify_interlocutors
        @already_notified = [form.context.current_user]

        conversation.interlocutors(originator).each do |recipient|
          notify(recipient) do
            ConversationMailer.new_conversation(originator, recipient, conversation).deliver_later
          end
          Decidim::PushNotificationMessageSender.new.new_conversation(originator, recipient, conversation).deliver
        end
      end

      # in order for a recipient to receive an email it should not have direct-messages disabled
      # if direct-messages are disabled, only send if they follow the sending user
      def notify(recipient)
        return unless recipient.accepts_conversation?(form.context.current_user)

        yield unless @already_notified.include?(recipient)
        @already_notified.push(recipient)
      end

      attr_reader :form
    end
  end
end
