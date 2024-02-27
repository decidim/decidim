# frozen_string_literal: true

module Decidim
  # A messsage from a conversation that will be sent as a push notification
  class PushNotificationMessage
    class InvalidActionError < StandardError; end

    include SanitizeHelper
    include Decidim::TranslatableAttributes

    def initialize(recipient:, conversation:, message:)
      @recipient = recipient
      @conversation = conversation
      @message = message
    end

    attr_reader :recipient, :conversation, :message

    alias user recipient

    def body
      decidim_html_escape(translated_attribute(message))
    end

    def icon
      organization.attached_uploader(:favicon).variant_url(:big, host: organization.host)
    end

    def url
      EngineRouter.new("decidim", {}).public_send(:conversation_path, host: organization.host, id: @conversation)
    end

    private

    def organization
      @organization ||= recipient.organization
    end
  end
end
