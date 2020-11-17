# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for Followers's registries
    # Searches for unique Followers for registered MetricOperations
    class FollowersMetricManage < Decidim::MetricManage
      def metric_name
        "followers"
      end

      def save
        query.each do |key, results|
          cumulative_value = results[:cumulative_users].count
          next if cumulative_value.zero?

          quantity_value = results[:quantity_users].count || 0
          space_type, space_id = key
          record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                         participatory_space_type: space_type, participatory_space_id: space_id,
                                                         organization: @organization)
          record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
          record.save!
        end
      end

      private

      # rubocop: disable Metrics/CyclomaticComplexity

      # Creates a Hashed structure with number of Followers grouped by
      #
      #  - ParticipatorySpace (type & ID)
      def query
        return @query if @query

        @query = retrieve_participatory_spaces.each_with_object({}) do |participatory_space, grouped_participants|
          key = [participatory_space.class.name, participatory_space.id]
          grouped_participants[key] = { cumulative_users: [], quantity_users: [] }
          if (operation_manifest = Decidim.metrics_operation.for(:followers, participatory_space.manifest.name))
            space_participants = operation_manifest.calculate(@day, participatory_space)
            grouped_participants[key].merge!(space_participants || {}) do |_key, grouped_users, space_users|
              grouped_users | space_users
            end
          end

          components = retrieve_components(participatory_space)
          components.each do |component|
            operation_manifest = Decidim.metrics_operation.for(:followers, component.manifest_name)
            next grouped_participants unless operation_manifest

            component_participants = operation_manifest.calculate(@day, component)
            grouped_participants[key].merge!(component_participants || {}) do |_key, grouped_users, component_users|
              grouped_users | component_users
            end
          end

          grouped_participants
        end
        @query
      end
      # rubocop: enable Metrics/CyclomaticComplexity
    end
  end
end
