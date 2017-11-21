# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a chat
    class ReplyToChat < Rectify::Command
      # Public: Initializes the command.
      #
      # chat - The chat to be updated.
      # form - A form object with the params.
      def initialize(chat, form)
        @chat = chat
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
        @message ||= chat.add_message(sender: sender, body: form.body)
      end

      def notify_interlocutors
        chat.interlocutors(sender).each do |recipient|
          if chat.unread_count(recipient) == 1
            ChatMailer.new_message(sender, recipient, chat).deliver_later
          end
        end
      end

      attr_reader :chat, :form
    end
  end
end
