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
          block_reasons: blocking&.justification,
          blocking_user: blocking_user&.presenter&.name
        }
      end

      private

      # The collection filters on `decidim_users.blocked_at`, but this
      # association is resolved through `decidim_users.block_id`. The two can
      # disagree, in which case there is no block to read the details from.
      def blocking = resource.blocking

      def blocking_user = blocking&.blocking_user
    end
  end
end
