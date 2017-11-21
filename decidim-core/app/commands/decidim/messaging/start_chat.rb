# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a chat
    class StartChat < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A chat form
      def initialize(form)
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

        if chat.save
          notify_interlocutors

          broadcast(:ok, chat)
        else
          broadcast(:invalid)
        end
      end

      private

      def chat
        @chat ||= Chat.start(
          originator: originator,
          interlocutors: [form.recipient],
          body: form.body
        )
      end

      def notify_interlocutors
        chat.interlocutors(originator).each do |recipient|
          ChatMailer.new_chat(originator, recipient, chat).deliver_later
        end
      end

      def originator
        form.current_user
      end

      attr_reader :form
    end
  end
end
