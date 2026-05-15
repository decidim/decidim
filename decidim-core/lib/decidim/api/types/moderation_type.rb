# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a content moderation record
    class ModerationType < Decidim::Api::Types::BaseObject
      description "A moderation detail"

      implements Decidim::Core::TimestampsInterface

      field :hidden_at, Decidim::Core::DateTimeType, "The date and time when the resource was hidden", null: true
      field :id, GraphQL::Types::ID, "The ID of the moderation", null: false
      field :report_count, GraphQL::Types::Int, "The number of reports of this resource", null: true
      field :reported_content, GraphQL::Types::String, "The content that has been reported", null: true
      field :reported_url, GraphQL::Types::String, "The URL of the resource that was reported", null: true
      field :reports, [Decidim::Core::ReportableType, { null: true }], "The reports of this resource", null: true

      def reported_url
        return "" unless object.reportable.respond_to?(:reported_content_url)

        object.reportable.reported_content_url
      end
    end
  end
end
