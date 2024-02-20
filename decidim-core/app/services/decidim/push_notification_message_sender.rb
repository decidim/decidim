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
    # rubocop:disable Lint/UnusedMethodArgument
    #
    # There are some parameters thar are not used in the method, but they are needed to
    # keep the same contract as the Decidim::Messaging::ConversationMailer
    def send_notification(from:, to:, conversation:, action:, message: nil, third_party: nil)
      @action = action
      @sender = to
      @third_party = third_party

      @notification = PushNotificationMessage.new(
        recipient: to,
        conversation:,
        message:
      )

      self
    end
    # rubocop:enable Lint/UnusedMethodArgument
    # rubocop:enable Metrics/ParameterLists

    def title
      get_subject(action: @action, sender: @sender, third_party: @third_party)
    end
  end
end
