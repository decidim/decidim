# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class serializes a ParticipatoryProcesses so can be exported to CSV, JSON or other
    # formats.
    class ParticipatoryProcessSerializer < Decidim::ParticipatoryProcesses::OpenDataParticipatoryProcessSerializer
      # Public: Exports a hash with the serialized data for this participatory_process.
      def serialize
        super.merge(
          {
            categories: serialize_categories,
            taxonomies:,
            attachments: {
              attachment_collections: serialize_attachment_collections,
              files: serialize_attachments
            },
            access_mode: resource.access_mode,
            weight: resource.weight,
            components: serialize_components,
            participatory_process_phases: serialize_participatory_process_phases
          }
        )
      end

      private

      def serialize_participatory_process_phases
        return unless resource.phases.any?

        resource.phases.map do |phase|
          {
            id: phase.try(:id),
            title: phase.try(:title),
            description: phase.try(:description),
            start_date: phase.try(:start_date),
            end_date: phase.try(:end_date),
            active: phase.active,
            position: phase.position
          }
        end
      end
    end
  end
end
