# frozen_string_literal: true

module Decidim
  module Messaging
    # A command with all the business logic for replying to a conversation
    class StartConversation < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A conversation form
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

        if conversation.save
          notify_interlocutors

          broadcast(:ok, conversation)
        else
          broadcast(:invalid)
        end
      end

      private

      def conversation
        @conversation ||= Conversation.start(
          originator: originator,
          interlocutors: [form.recipient],
          body: form.body
        )
      end

      def notify_interlocutors
        conversation.interlocutors(originator).each do |recipient|
          ConversationMailer.new_conversation(originator, recipient, conversation).deliver_later
        end
      end

      def originator
        form.current_user
      end

      attr_reader :form
    end
  end
end
