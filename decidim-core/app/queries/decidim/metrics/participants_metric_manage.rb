# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for Participant's registries
    # Searches for Participants for registered MetricOperations
    class ParticipantsMetricManage < Decidim::MetricManage
      # This list limits the number of components involved in this Metric
      AVAILABLE_COMPONENTS = %w(proposals debates surveys budgets).freeze

      def metric_name
        "participants"
      end

      def save
        return @registry if @registry

        @registry = []
        query.each do |key, results|
          cumulative_value = results[:cumulative_users].count
          next if cumulative_value.zero?

          quantity_value = results[:quantity_users].count || 0
          space_type, space_id = key
          record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                         participatory_space_type: space_type, participatory_space_id: space_id,
                                                         organization: @organization)
          record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
          @registry << record
        end
        @registry.each(&:save!)
        @registry
      end

      private

      # rubocop: disable Metrics/CyclomaticComplexity

      # Creates a Hashed structure with number of Participants grouped by
      #
      #  - ParticipatorySpace (type & ID)
      def query
        return @query if @query

        @query = retrieve_participatory_spaces.each_with_object({}) do |participatory_space, grouped_participants|
          key = [participatory_space.class.name, participatory_space.id]
          grouped_participants[key] = { cumulative_users: [], quantity_users: [] }
          components = retrieve_components(participatory_space)
          components.each do |component|
            operation_manifest = Decidim.metrics_operation.for(:participants, component.manifest_name)
            next grouped_participants unless operation_manifest

            component_participants = operation_manifest.calculate(@day, component)
            grouped_participants[key].merge!(component_participants || {}) do |_key, grouped_users, component_users|
              grouped_users | component_users
            end
          end

          # Special case for comments ONLY
          operation_manifest = Decidim.metrics_operation.for(:participants, :comments)
          next grouped_participants unless operation_manifest

          comments_participants = operation_manifest.calculate(@day, participatory_space)
          grouped_participants[key].merge!(comments_participants || {}) do |_key, grouped_users, comment_users|
            grouped_users | comment_users
          end
          grouped_participants
        end
        @query
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      # Search for all components published, within a fixed list of available
      def retrieve_components(participatory_space)
        super.where(manifest_name: AVAILABLE_COMPONENTS)
      end
    end
  end
end
