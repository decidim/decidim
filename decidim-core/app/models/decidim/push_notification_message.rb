# frozen_string_literal: true

module Decidim
  # A messsage from a conversation that will be sent as a push notification
  class PushNotificationMessage
    class InvalidActionError < StandardError; end

    def initialize(recipient:, conversation:, message:)
      @recipient = recipient
      @conversation = conversation
      @message = message
    end

    attr_reader :recipient, :conversation, :message

    include SanitizeHelper

    def body
      decidim_escape_translated(message)
    end

    def user
      recipient
    end

    # TODO: check if icon is correct
    def icon
      "fi-question-answer-line"
    end

    def url
      EngineRouter.new("decidim", {}).public_send(:conversation_path, host: @recipient.organization.host, id: @conversation)
    end
  end
end
