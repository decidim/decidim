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
            taxonomies: serialize_taxonomies(resource),
            attachments: {
              attachment_collections: serialize_attachment_collections,
              files: serialize_attachments
            },
            private_space: resource.private_space,
            weight: resource.weight,
            components: serialize_components,
            participatory_process_steps: serialize_participatory_process_steps
          }
        )
      end

      private

      def serialize_participatory_process_steps
        return unless resource.steps.any?

        resource.steps.map do |step|
          {
            id: step.try(:id),
            title: step.try(:title),
            description: step.try(:description),
            start_date: step.try(:start_date),
            end_date: step.try(:end_date),
            cta_path: step.try(:cta_path),
            cta_text: step.try(:cta_text),
            active: step.active,
            position: step.position
          }
        end
      end
    end
  end
end
