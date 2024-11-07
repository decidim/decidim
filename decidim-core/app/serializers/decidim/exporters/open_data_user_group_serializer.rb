# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataUserGroupSerializer < Decidim::Exporters::Serializer
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
          avatar_url: presented.avatar_url(:thumb),
          profile_url: presented.profile_url,
          deleted: presented.deleted?,
          badge: presented.badge,
          members_count: resource.accepted_memberships.count,
          members: {
            id: resource.accepted_users.collect(&:id),
            name: resource.accepted_users.collect(&:name)
          }
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
