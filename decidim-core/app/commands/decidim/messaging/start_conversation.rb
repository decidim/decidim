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
byebug
        if conversation.save
          notify_interlocutors
          notify_comanagers if originator.is_a?(UserGroup)

          broadcast(:ok, conversation)
        else
          broadcast(:invalid)
        end
      end

      private

      def conversation
        @conversation ||= Conversation.start(
          originator: originator,
          interlocutors: form.recipient,
          body: form.body,
          user: form.context.current_user
        )
      end

      def notify_interlocutors
        @already_notified = [form.context.current_user]
        valid_interlocutors.each do |recipient|
          next if @already_notified.include?(recipient)

          ConversationMailer.new_conversation(originator, recipient, conversation).deliver_later
          @already_notified.push(recipient)
        end
      end

      def notify_comanagers
        originator.managers.each do |recipient|
          next if @already_notified.include?(recipient)

          ConversationMailer.comanagers_new_conversation(form.context.current_user, originator, recipient, conversation).deliver_later
          @already_notified.push(recipient)
        end
      end

      # returns all interlocutors should be notified, adding group managers in case of a group
      def valid_interlocutors
        conversation.interlocutors(originator).flat_map do |recipient|
          recipient.is_a?(UserGroup) ? recipient.managers : recipient
        end
      end

      def originator
        form.context.sender
      end

      attr_reader :form
    end
  end
end
