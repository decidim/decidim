# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataUserSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          id: resource.id,
          name: presented.name,
          nickname: presented.nickname,
          about: presented.about,
          avatar_url: presented.avatar_url(:thumb),
          profile_url: presented.profile_url,
          direct_messages_enabled: (resource.direct_message_types != "followed-only"),
          deleted: presented.deleted?,
          badge: presented.badge
        }
      end

      private

      attr_reader :resource

      def presented
        @presented ||= resource.presenter
      end
    end
  end
end
