# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessDemocraticQualityStatsPresenter
      attr_reader :content_block, :participatory_process

      def initialize(content_block, participatory_process)
        @content_block = content_block
        @participatory_process = participatory_process
      end

      def stats
        @stats ||= {
          global_score: calculate_global_score, precision: 2,
          # Automatic metrics
          influence: calculate_influence,
          hybridization: calculate_hybridization,
          accountability: calculate_accountability,
          traceability: calculate_traceability,
          # Qualitative metrics
          inclusiveness: calculate_inclusiveness,
          relevance: calculate_relevance,
          citizen_influence: calculate_citizen_influence,
          accessibility: calculate_accessibility
        }
      end

      def finished_survey?
        settings.migrant_groups_invited != -1 &&
          settings.cultural_origins_participation != -1 &&
          settings.functional_diversity_invited != -1 &&
          settings.functional_diversity_participation != -1 &&
          settings.relevance_percentage != -1 &&
          settings.citizen_influence_level != -1 &&
          settings.languages_count != -1 &&
          settings.venue_accessibility != -1
      end

      private

      # Global score

      def calculate_global_score
        automatic_metrics = (calculate_influence + calculate_hybridization + calculate_accountability + calculate_traceability) / 4.0

        if finished_survey?
          qualitative_metrics = (calculate_inclusiveness + calculate_relevance + calculate_citizen_influence + calculate_accessibility) / 4.0
          (automatic_metrics + qualitative_metrics) / 2.0
        else
          automatic_metrics
        end
      end

      # Qualitative metrics

      def calculate_inclusiveness
        (settings.migrant_groups_invited + settings.cultural_origins_participation + settings.functional_diversity_invited + settings.functional_diversity_participation) / 4.0
      end

      def calculate_relevance
        settings.relevance_percentage
      end

      def calculate_citizen_influence
        settings.citizen_influence_level
      end

      def calculate_accessibility
        (settings.venue_accessibility + settings.languages_count) / 2.0
      end

      def settings
        content_block.settings
      end

      # Automatic metrics

      def calculate_accountability
        (calculate_answered_proposals + calculate_linked_results + calculate_completed_results) / 3.0
      end

      def calculate_influence
        percentage_to_scale(all_proposals.accepted.count, all_proposals.count)
      end

      def calculate_hybridization
        quality_meetings = all_meetings.where.not(type_of_meeting: Decidim::Meetings::Meeting::TYPE_OF_MEETING[:online])
                                       .where.not(end_time: nil)

        percentage_to_scale(quality_meetings.count, all_meetings.count)
      end

      def calculate_answered_proposals
        percentage_to_scale(all_proposals.answered.count, all_proposals.count)
      end

      def calculate_linked_results
        linked_results = all_proposals.joins(:resource_links_from)
                                      .where(decidim_resource_links: { name: "linked_results", to_type: "Decidim::Accountability::Result" })
        percentage_to_scale(linked_results.count, all_proposals.count)
      end

      def calculate_completed_results
        completed_results = all_accountability_results.where(progress: 100)

        percentage_to_scale(completed_results.count, all_accountability_results.count)
      end

      def calculate_traceability
        linked_proposals_ids = (all_proposals.joins(:resource_links_from).pluck(:id) +
                               all_proposals.joins(:resource_links_to).pluck(:id)).uniq

        percentage_to_scale(linked_proposals_ids.count, all_proposals.count)
      end

      def percentage_to_scale(value, total)
        return 0 if total.zero?

        percentage = (value.to_f / total) * 100
        case percentage
        when 0..20 then 1.0
        when 20.1..40 then 2.0
        when 40.1..60 then 3.0
        when 60.1..80 then 4.0
        else 5.0
        end
      end

      def all_proposals
        Decidim::Proposals::Proposal.where(component: proposals_components)
      end

      def all_meetings
        Decidim::Meetings::Meeting.where(component: meetings_components)
      end

      def all_accountability_results
        Decidim::Accountability::Result.where(component: accountability_components)
      end

      def proposals_components
        @proposals_components ||= components.where(manifest_name: "proposals")
      end

      def meetings_components
        @meetings_components ||= components.where(manifest_name: "meetings")
      end

      def accountability_components
        @accountability_components ||= components.where(manifest_name: "accountability")
      end

      def components
        @components ||= participatory_process.components
      end
    end
  end
end
