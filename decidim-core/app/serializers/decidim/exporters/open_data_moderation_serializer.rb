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
          reported_url:,
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

      private

      # `Decidim::Moderation#reportable` is polymorphic, so the database cannot
      # enforce the reference, and the moderation row outlives the resource it
      # points at. Both of the cases below leave the moderation in the export
      # collection with no URL to build.
      def reported_url
        reportable = resource.reportable

        # The resource is gone. Reportables such as proposals and meetings are
        # soft-deletable while `belongs_to :reportable` does not use
        # `with_deleted`, so moving one to the trash is enough for this.
        return if reportable.nil?

        # The component is gone but the resource is not: trashing a component
        # does not trash its contents. `ResourceLocatorPresenter#route_proxy`
        # falls back to the resource itself when `component` is nil, and
        # `EngineRouter.main_proxy` then calls `mounted_engine` on it, which
        # only components and participatory spaces respond to.
        return if reportable.is_a?(Decidim::HasComponent) && reportable.component.nil?

        reportable.reported_content_url
      end
    end
  end
end
