# frozen_string_literal: true

module Decidim
  # This class serializes a Message so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataConversationSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a conversation.
      def initialize(conversation)
        @conversation = conversation
      end

      # Public: Exports a hash with the serialized data for this conversation.
      def serialize
        {
          id: conversation.id,
          messages: messages,
          created_at: conversation.created_at,
          updated_at: conversation.updated_at
        }
      end

      private

      attr_reader :conversation
      alias resource conversation

      def messages
        conversation.messages.map do |message|
          {
            message_id: message.id,
            sender_id: message.sender.id,
            sender_name: message.sender.name,
            body: message.body,
            created_at: message.created_at,
            updated_at: message.updated_at
          }
        end
      end
    end
  end
end
