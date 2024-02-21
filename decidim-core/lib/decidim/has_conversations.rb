# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasConversations
    extend ActiveSupport::Concern

    included do
      def new_conversation(originator, user, conversation)
        send_notification(
          from: originator,
          to: user,
          conversation:,
          message: conversation.messages.first.body,
          action: "new_conversation"
        )
      end

      def new_group_conversation(originator, manager, conversation, group)
        send_notification(
          from: originator,
          to: manager,
          conversation:,
          message: conversation.messages.first.body,
          action: "new_group_conversation",
          third_party: group
        )
      end

      def comanagers_new_conversation(group, user, conversation, manager)
        send_notification(
          from: group,
          to: user,
          conversation:,
          message: conversation.messages.first.body,
          action: "comanagers_new_conversation",
          third_party: manager
        )
      end

      def new_message(sender, user, conversation, message)
        send_notification(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "new_message"
        )
      end

      def new_group_message(sender, user, conversation, message, group)
        send_notification(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "new_group_message",
          third_party: group
        )
      end

      def comanagers_new_message(sender, user, conversation, message, manager)
        send_notification(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "comanagers_new_message",
          third_party: manager
        )
      end

      private

      def get_subject(action:, sender:, third_party:)
        I18n.t(
          "conversation_mailer.#{action}.subject",
          scope: "decidim.messaging",
          sender: sender.name,
          manager: third_party&.name,
          group: third_party&.name
        )
      end

      def send_notification
        raise NotImplementedError, "You must define a send_notification method"
      end
    end
  end
end
