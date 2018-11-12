# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for Participant's registries
    class ParticipantsMetricManage < Decidim::MetricManage
      # Searches for Participants for registered MetricOperations
      #
      # !! Comments is an special case because it does not depend
      #    in Participatory Space's Components, but in all possible
      #    Components available

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
            grouped_participants[key].merge!(component_participants || {}) { |_key, g_p, c_p| g_p | c_p }
          end

          # Special case for comments ONLY
          operation_manifest = Decidim.metrics_operation.for(:participants, :comments)
          next grouped_participants unless operation_manifest
          # raise "HEY COMMENTS: #{operation_manifest.as_json}"
          comments_participants = operation_manifest.calculate(@day, participatory_space)
          grouped_participants[key].merge!(comments_participants || {}) { |_key, g_p, c_p| g_p | c_p }
          grouped_participants
        end
        @query
      end

      # Search for all Participatory Space manifests and then all records available
      # Limited to ParticipatoryProcesses only
      def retrieve_participatory_spaces
        Decidim.participatory_space_manifests.map do |space_manifest|
          next unless space_manifest.name == :participatory_processes # Temporal limitation
          space_manifest.participatory_spaces.call(@organization)
        end.flatten.compact
      end

      # Search for all components published, within a fixed list of available
      def retrieve_components(participatory_space)
        participatory_space.components.published.where(manifest_name: AVAILABLE_COMPONENTS)
      end
    end
  end
end
