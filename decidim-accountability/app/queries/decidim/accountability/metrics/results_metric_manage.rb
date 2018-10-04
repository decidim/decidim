# frozen_string_literal: true

module Decidim
  module Accountability
    module Metrics
      class ResultsMetricManage < Decidim::MetricManage
        def metric_name
          "results"
        end

        def save
          return @registry if @registry

          @registry = []
          cumulative.each do |key, cumulative_value|
            next if cumulative_value.zero?
            quantity_value = quantity[key] || 0
            category_id, space_type, space_id, related_object_type, related_object_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           organization: @organization, decidim_category_id: category_id,
                                                           participatory_space_type: space_type, participatory_space_id: space_id,
                                                           related_object_type: related_object_type, related_object_id: related_object_id)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            @registry << record
          end
          @registry.each(&:save!)
          @registry
        end

        private

        def query
          return @query if @query

          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(@organization).public_spaces
          end
          components = Decidim::Component.where(participatory_space: spaces).published
          @query = Decidim::Accountability::Result.where(component: components).joins(:component)
                                                  .left_outer_joins(:category)
          @query = @query.where("decidim_accountability_results.created_at <= ?", end_time)
          @query = @query.group("decidim_categorizations.decidim_category_id", :participatory_space_type, :participatory_space_id,
                                "decidim_components.manifest_name", "decidim_components.id")

          @query
        end

        def quantity
          @quantity ||= query.where("decidim_accountability_results.created_at >= ?", start_time).count
        end
      end
    end
  end
end
