# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      # Cell for the democratic quality stats settings form content block.
      class DemocraticQualityStatsSettingsFormCell < Decidim::ContentBlocks::BaseCell
        alias form model

        def content_block
          options[:content_block]
        end

        def option_scope
          "decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form"
        end

        def settings_options
          {
            functional_diversity_invited: [
              [t("inclusiveness.functional_diversity_invited.options.zero", scope: option_scope), 0],
              [t("inclusiveness.functional_diversity_invited.options.one", scope: option_scope), 1],
              [t("inclusiveness.functional_diversity_invited.options.two_five", scope: option_scope), 2.5],
              [t("inclusiveness.functional_diversity_invited.options.five", scope: option_scope), 5]
            ],
            languages_communicated: [
              [t("inclusiveness.languages_communicated.options.one", scope: option_scope), 1],
              [t("inclusiveness.languages_communicated.options.two_five", scope: option_scope), 2.5],
              [t("inclusiveness.languages_communicated.options.five", scope: option_scope), 5]
            ],
            mobility_meeting_access: [
              [t("inclusiveness.mobility_meeting_access.options.zero", scope: option_scope), 0],
              [t("inclusiveness.mobility_meeting_access.options.two_five", scope: option_scope), 2.5],
              [t("inclusiveness.mobility_meeting_access.options.five", scope: option_scope), 5]
            ],
            participation_scheduling_times: [
              [t("inclusiveness.participation_scheduling_times.options.zero", scope: option_scope), 0],
              [t("inclusiveness.participation_scheduling_times.options.two_five", scope: option_scope), 2.5],
              [t("inclusiveness.participation_scheduling_times.options.five", scope: option_scope), 5]
            ],
            digital_support_offered: [
              [t("inclusiveness.digital_support_offered.options.zero", scope: option_scope), 0],
              [t("inclusiveness.digital_support_offered.options.two_five", scope: option_scope), 2.5],
              [t("inclusiveness.digital_support_offered.options.five", scope: option_scope), 5]
            ],
            citizen_influence_level: [
              [t("citizen_influence.citizen_influence_level.options.one", scope: option_scope), 1],
              [t("citizen_influence.citizen_influence_level.options.two", scope: option_scope), 2],
              [t("citizen_influence.citizen_influence_level.options.three", scope: option_scope), 3],
              [t("citizen_influence.citizen_influence_level.options.four", scope: option_scope), 4],
              [t("citizen_influence.citizen_influence_level.options.five", scope: option_scope), 5]
            ],
            citizen_decisional_intervention: [
              [t("citizen_influence.citizen_decisional_intervention.options.one", scope: option_scope), 1],
              [t("citizen_influence.citizen_decisional_intervention.options.two", scope: option_scope), 2],
              [t("citizen_influence.citizen_decisional_intervention.options.three", scope: option_scope), 3],
              [t("citizen_influence.citizen_decisional_intervention.options.four", scope: option_scope), 4],
              [t("citizen_influence.citizen_decisional_intervention.options.five", scope: option_scope), 5]
            ],
            published_information_clarity: [
              [t("informativeness.published_information_clarity.options.zero", scope: option_scope), 0],
              [t("informativeness.published_information_clarity.options.one", scope: option_scope), 1],
              [t("informativeness.published_information_clarity.options.two_five", scope: option_scope), 2.5],
              [t("informativeness.published_information_clarity.options.five", scope: option_scope), 5]
            ],
            information_provided: [
              [t("informativeness.information_provided.options.zero", scope: option_scope), 0],
              [t("informativeness.information_provided.options.one", scope: option_scope), 1],
              [t("informativeness.information_provided.options.two_five", scope: option_scope), 2.5],
              [t("informativeness.information_provided.options.five", scope: option_scope), 5]
            ]
          }
        end

        def input_name(name)
          "content_block[settings][#{name}]"
        end
      end
    end
  end
end
