# frozen_string_literal: true

module Decidim
  # A wrapper for preparing push notifications messages from conversations
  # It respects the same contract as the Decidim::Messaging::ConversationMailer
  class PushNotificationMessageSender
    include HasConversations

    def deliver
      SendPushNotification.new.perform(@notification, title)
    end

    private

    # rubocop:disable Metrics/ParameterLists
    def send_notification(from:, to:, conversation:, action:, message: nil, third_party: nil)
      @action = action
      @sender = to
      @third_party = third_party

      @notification = PushNotificationMessage.new(
        sender: from,
        recipient: to,
        conversation:,
        message:,
        third_party:,
        action:
      )

      self
    end
    # rubocop:enable Metrics/ParameterLists

    def title
      get_subject(action: @action, sender: @sender, third_party: @third_party)
    end
  end
end
