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
            migrant_groups_invited: [
              [t("inclusiveness.migrant_groups_invited.options.five", scope: option_scope), 5],
              [t("inclusiveness.migrant_groups_invited.options.zero", scope: option_scope), 0]
            ],
            cultural_origins_participation: [
              [t("inclusiveness.cultural_origins_participation.options.one", scope: option_scope), 1],
              [t("inclusiveness.cultural_origins_participation.options.two", scope: option_scope), 2],
              [t("inclusiveness.cultural_origins_participation.options.three", scope: option_scope), 3],
              [t("inclusiveness.cultural_origins_participation.options.four", scope: option_scope), 4],
              [t("inclusiveness.cultural_origins_participation.options.five", scope: option_scope), 5]
            ],
            functional_diversity_invited: [
              [t("inclusiveness.functional_diversity_invited.options.five", scope: option_scope), 5],
              [t("inclusiveness.functional_diversity_invited.options.zero", scope: option_scope), 0]
            ],
            functional_diversity_participation: [
              [t("inclusiveness.functional_diversity_participation.options.one", scope: option_scope), 1],
              [t("inclusiveness.functional_diversity_participation.options.two", scope: option_scope), 2],
              [t("inclusiveness.functional_diversity_participation.options.three", scope: option_scope), 3],
              [t("inclusiveness.functional_diversity_participation.options.four", scope: option_scope), 4],
              [t("inclusiveness.functional_diversity_participation.options.five", scope: option_scope), 5]
            ],
            relevance_percentage: [
              [t("relevance.relevance_percentage.options.one", scope: option_scope), 1],
              [t("relevance.relevance_percentage.options.two", scope: option_scope), 2],
              [t("relevance.relevance_percentage.options.three", scope: option_scope), 3],
              [t("relevance.relevance_percentage.options.four", scope: option_scope), 4],
              [t("relevance.relevance_percentage.options.five", scope: option_scope), 5]
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
            languages_count: [
              [t("accessibility.languages_count.options.one", scope: option_scope), 1],
              [t("accessibility.languages_count.options.two_five", scope: option_scope), 2.5],
              [t("accessibility.languages_count.options.five", scope: option_scope), 5]
            ],
            venue_accessibility: [
              [t("accessibility.venue_accessibility.options.zero", scope: option_scope), 0],
              [t("accessibility.venue_accessibility.options.two_five", scope: option_scope), 2.5],
              [t("accessibility.venue_accessibility.options.five", scope: option_scope), 5]
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
