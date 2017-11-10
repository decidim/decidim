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

        chat = Chat.start(
          originator: form.current_user,
          interlocutors: [form.recipient],
          body: form.body
        )

        if chat.save
          broadcast(:ok, chat)
        else
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form
    end
  end
end
