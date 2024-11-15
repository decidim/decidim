# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataBlockedUserSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          user_id: resource.user.id,
          blocked_at: resource.user.blocked_at,
          about: resource.user.about,
          reasons: resource.reports.map(&:reason),
          details: resource.reports.map(&:details),
          block_reasons: resource.blocking.justification,
          blocking_user: resource.blocking.blocking_user.presenter.name
        }
      end
    end
  end
end
