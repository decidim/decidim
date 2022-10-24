# frozen_string_literal: true

module Decidim
  # This class search for objects related to Metrics, and creates a new registry within
  # its own parameters
  class MetricManage
    def self.for(day_string, organization)
      new(day_string, organization)
    end

    def initialize(day_string, organization)
      @day = day_string.present? ? Date.parse(day_string) : Time.zone.yesterday
      raise ArgumentError, "[ERROR] Malformed `day` argument. Format must be `YYYY-MM-DD` and in the past" if @day > Time.zone.today

      @day ||= Time.zone.yesterday
      @organization = organization
      @metric_name = metric_name
    end

    def metric_name
      ""
    end

    def valid?
      @day.present?
    end

    def save
      return @registry if @registry

      return if cumulative.zero? && %w(blocked_users reported_users user_reports).exclude?(@metric_name)

      @registry = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name, organization: @organization)
      @registry.assign_attributes(cumulative:, quantity:)
      @registry.save!
      @registry
    end

    private

    def start_time
      @start_time ||= @day.beginning_of_day
    end

    def end_time
      @end_time ||= @day.end_of_day
    end

    def query
      raise "Not implemented"
    end

    def cumulative
      @cumulative ||= query.count
    end

    def quantity
      @quantity ||= cumulative
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
      participatory_space.components.published
    end

    # Returns the ids for all the published components in the given +spaces+.
    def visible_components_from_spaces(spaces)
      Decidim::Component.where(participatory_space: spaces).published
    end
  end
end
