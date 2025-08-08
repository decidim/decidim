# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataModerationSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          id: resource.id,
          hidden_at: resource.hidden_at,
          report_count: resource.report_count,
          reported_url: resource.reportable.reported_content_url,
          reportable_type: resource.decidim_reportable_type,
          reportable_id: resource.decidim_reportable_id,
          reported_content: resource.reported_content,
          reports: {
            reasons: resource.reports.map(&:reason),
            locale: resource.reports.map(&:locale),
            details: resource.reports.map(&:details)
          }
        }
      end
    end
  end
end
