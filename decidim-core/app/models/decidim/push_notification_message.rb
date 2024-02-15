# frozen_string_literal: true

module Decidim
  # A messsage from a conversation that will be sent as a push notification
  class PushNotificationMessage
    class InvalidActionError < StandardError; end

    def initialize(sender:, recipient:, conversation:, message:, third_party:, action:) # rubocop:disable Metrics/ParameterLists
      @sender = sender
      @recipient = recipient
      @conversation = conversation
      @message = message
      @third_party = third_party
      @action = validate_action(action)
    end

    ACTIONS = %w(
      comanagers_new_conversation
      comanagers_new_message
      new_conversation
      new_group_conversation
      new_group_message
      new_message
    ).freeze

    attr_reader :sender, :recipient, :conversation, :message, :action, :third_party

    include SanitizeHelper

    def body
      decidim_escape_translated(message)
    end

    def event_class
      "Decidim::Messaging::Message"
    end

    def user
      recipient
    end

    # TODO: add icon
    def icon
      "fi-question-answer-line"
    end

    def url
      EngineRouter.new("decidim", {}).public_send(:conversation_path, host: @sender.organization.host, id: @conversation)
    end

    private

    def validate_action(action)
      raise InvalidActionError unless ACTIONS.include?(action)

      action
    end
  end
end
