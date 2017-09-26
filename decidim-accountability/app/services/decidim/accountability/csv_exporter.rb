# frozen_string_literal: true
require "csv"

module Decidim
  module Accountability
    # This class handles exporting results to a CSV file.
    # Needs a `current_feature` param with a `Decidim::Feature`
    class CSVExporter

      # Public: Initializes the service.
      # feature       - A Decidim::Feature to import the results into.
      def initialize(feature)
        @feature = feature
      end

      def export
        results = Decidim::Accountability::Result.where(feature: @feature).order(:id)

        generated_csv = CSV.generate(headers: true) do |csv|
          headers = [
            "result_id",
            "decidim_category_id",
            "decidim_scope_id",
            "parent_id",
            "external_id",
            "start_date",
            "end_date",
            "decidim_accountability_status_id",
            "progress",
            "proposal_ids"
          ]

          available_locales = @feature.participatory_space.organization.available_locales
          available_locales.each do |locale|
            headers << "title_#{locale}"
            headers << "description_#{locale}"
          end

          csv << headers

          results.find_each do |result|
            row = Rails.cache.fetch("#{result.cache_key}/csv") do
              row_for_result(result, available_locales)
            end

            csv << row
          end
        end

        generated_csv
      end

      private

      def row_for_result(result, available_locales)
        row = [
          result.id,
          result.category.try(:id),
          result.decidim_scope_id,
          result.parent_id,
          result.external_id,
          result.start_date,
          result.end_date,
          result.decidim_accountability_status_id,
          result.progress,
          result.linked_resources(:proposals, "included_proposals").pluck(:id).sort.join(";"),
        ]
        available_locales.each do |locale|
          row << result.title[locale]
          row << result.description[locale]
        end

        row
      end
    end
  end
end
