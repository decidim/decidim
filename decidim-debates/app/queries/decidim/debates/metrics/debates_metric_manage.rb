# frozen_string_literal: true

module Decidim
  module Debates
    module Metrics
      class DebatesMetricManage < Decidim::MetricManage
        def metric_name
          "debates"
        end

        def save
          return @registry if @registry

          @registry = []
          cumulative.each do |key, cumulative_value|
            next if cumulative_value.zero?

            quantity_value = quantity[key] || 0
            category_id, space_type, space_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           organization: @organization, decidim_category_id: category_id,
                                                           participatory_space_type: space_type, participatory_space_id: space_id)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            @registry << record
          end
          @registry.each(&:save!)
          @registry
        end

        private

        def query
          return @query if @query

          components = Decidim::Component.where(participatory_space: retrieve_participatory_spaces).published
          @query = Decidim::Debates::Debate.where(component: components).joins(:component)
                                           .left_outer_joins(:category)
          @query = @query.where("decidim_debates_debates.start_time <= ?", end_time)
          @query = @query.group("decidim_categorizations.decidim_category_id",
                                :participatory_space_type,
                                :participatory_space_id)
          @query
        end

        def quantity
          @quantity ||= query.where("decidim_debates_debates.start_time >= ?", start_time).count
        end
      end
    end
  end
end
