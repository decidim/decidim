# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Presenter class for calculating and displaying democratic quality statistics
    # for a participatory process. It handles both automatic metrics and manual
    # auto-evaluation metrics.
    class ParticipatoryProcessDemocraticQualityStatsPresenter
      attr_reader :content_block, :participatory_process

      def initialize(content_block, participatory_process)
        @content_block = content_block
        @participatory_process = participatory_process
      end

      def stats
        @stats ||= {
          global_score: calculate_global_score, precision: 2,
          # Automatic metrics based on platform data
          automatic: {
            influence: calculate_automatic_influence,
            hybridization: calculate_automatic_hybridization,
            transparency: calculate_automatic_transparency,
            traceability: calculate_automatic_traceability
          },
          # Auto-evaluation metrics based on survey responses
          auto_evaluation: {
            inclusiveness: calculate_auto_evaluation_inclusiveness,
            relevance: calculate_auto_evaluation_relevance,
            citizen_influence: calculate_auto_evaluation_citizen_influence,
            accessibility: calculate_auto_evaluation_accessibility
          }
        }
      end

      # @return [Boolean]
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

      # @return [Float]
      def calculate_global_score
        automatic_metrics = (
          calculate_automatic_influence +
          calculate_automatic_hybridization +
          calculate_automatic_transparency +
          calculate_automatic_traceability
        ) / 4.0

        if finished_survey?
          auto_evaluation_metrics = (
            calculate_auto_evaluation_inclusiveness +
            calculate_auto_evaluation_relevance +
            calculate_auto_evaluation_citizen_influence +
            calculate_auto_evaluation_accessibility
          ) / 4.0

          (automatic_metrics + auto_evaluation_metrics) / 2.0
        else
          automatic_metrics
        end
      end

      # Automatic metrics

      # Influence

      # @return [Float]
      def calculate_automatic_influence
        (approved_proposals_score +
          approved_citizen_proposals_relative_score +
          approved_citizen_proposals_absolute_score +
          citizen_linked_results_score) / 4.0
      end

      # @return [Float]
      def approved_proposals_score
        percentage_to_scale(all_proposals.accepted.count, all_proposals.count)
      end

      # @return [Float]
      def approved_citizen_proposals_relative_score
        approved_citizen_proposals_count = all_proposals.accepted.where(author_type: "Decidim::User").count
        total_citizen_proposals_count = all_proposals.where(author_type: "Decidim::User").count

        percentage_to_scale(approved_citizen_proposals_count, total_citizen_proposals_count)
      end

      # @return [Float]
      def approved_citizen_proposals_absolute_score
        approved_citizen_proposals_count = all_proposals.accepted.where(author_type: "Decidim::User").count

        percentage_to_scale(approved_citizen_proposals_count, all_proposals.accepted.count)
      end

      # @return [Float]
      def citizen_linked_results_score
        citizen_results = all_proposals
                          .joins(:resource_links_from)
                          .where(
                            author_type: "Decidim::User",
                            decidim_resource_links: {
                              name: "linked_results",
                              to_type: "Decidim::Accountability::Result"
                            }
                          )

        percentage_to_scale(citizen_results.count, all_accountability_results.count)
      end

      # Hybridization

      # @return [Float]
      def calculate_automatic_hybridization
        (meetings_component_score +
           meetings_online_score +
           meetings_in_person_score +
           meetings_hybrid_score +
           meetings_with_proposals_score) / 5.0
      end

      # @return [Float]
      def meetings_component_score
        components.where(manifest_name: "meetings").any? ? 5.0 : 0.0
      end

      # @return [Float]
      def meetings_online_score
        all_meetings.online.any? ? 5.0 : 0.0
      end

      # @return [Float]
      def meetings_in_person_score
        all_meetings.in_person.any? ? 5.0 : 0.0
      end

      # @return [Float]
      def meetings_hybrid_score
        all_meetings.hybrid.any? ? 5.0 : 0.0
      end

      # @return [Float]
      def meetings_with_proposals_score
        if all_meetings.joins(:resource_links_to)
                       .where(
                         decidim_resource_links: {
                           name: "proposals_from_meeting",
                           to_type: "Decidim::Meetings::Meeting"
                         }
                       )
                       .any?
          5.0
        else
          0.0
        end
      end

      # Transparency

      # @return [Float]
      def calculate_automatic_transparency
        [
          answered_proposals_score,
          completed_results_score
        ].sum / 2.0
      end

      # @return [Float]
      def answered_proposals_score
        percentage_to_scale(all_proposals.answered.count, all_proposals.count)
      end

      # @return [Float]
      def completed_results_score
        results = all_accountability_results.where(progress: 100)
        percentage_to_scale(results.count, all_accountability_results.count)
      end

      # Traceability

      # @return [Float]
      def calculate_automatic_traceability
        [
          proposals_with_history_score,
          linked_results_score,
          quality_meetings_score,
          proposals_linked_to_budgets_score
        ].sum / 4.0
      end

      # @return [Float]
      def proposals_with_history_score
        linked_proposals_ids = (
          all_proposals.joins(:resource_links_from).pluck(:id) +
          all_proposals.joins(:resource_links_to).pluck(:id)
        ).uniq

        percentage_to_scale(linked_proposals_ids.count, all_proposals.count)
      end

      # @return [Float]
      def linked_results_score
        results = all_proposals
                  .joins(:resource_links_from)
                  .where(
                    decidim_resource_links: {
                      name: "linked_results",
                      to_type: "Decidim::Accountability::Result"
                    }
                  )
        percentage_to_scale(results.count, all_proposals.count)
      end

      # @return [Float]
      def quality_meetings_score
        meetings = all_meetings
                   .where.not(type_of_meeting: Decidim::Meetings::Meeting::TYPE_OF_MEETING[:online])
                   .where.not(end_time: nil)

        percentage_to_scale(meetings.count, all_meetings.count)
      end

      # @return [Float]
      def proposals_linked_to_budgets_score
        proposals = all_proposals
                    .joins(:resource_links_to)
                    .where(decidim_resource_links: { name: "included_proposals", from_type: "Decidim::Budgets::Project" })

        percentage_to_scale(proposals.count, all_proposals.count)
      end

      # Auto-evaluation metrics

      # @return [Float]
      def calculate_auto_evaluation_inclusiveness
        [
          settings.migrant_groups_invited,
          settings.cultural_origins_participation,
          settings.functional_diversity_invited,
          settings.functional_diversity_participation
        ].sum / 4.0
      end

      # @return [Float]
      def calculate_auto_evaluation_relevance
        settings.relevance_percentage
      end

      # @return [Float]
      def calculate_auto_evaluation_citizen_influence
        settings.citizen_influence_level
      end

      # @return [Float]
      def calculate_auto_evaluation_accessibility
        (settings.venue_accessibility + settings.languages_count) / 2.0
      end

      # @return [Float]
      def percentage_to_scale(value, total)
        return 1.0 if total.zero?

        percentage = (value.to_f / total) * 100
        case percentage
        when 0..20 then 1.0
        when 20.1..40 then 2.0
        when 40.1..60 then 3.0
        when 60.1..80 then 4.0
        else 5.0
        end
      end

      def settings
        content_block.settings
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
