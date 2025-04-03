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

        def i18n_scope
          "decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form"
        end

        def settings_options
          {
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.migrant_groups_invited.options.five')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.migrant_groups_invited.options.zero')
            migrant_groups_invited: [
              [t("inclusiveness.migrant_groups_invited.options.five", scope: i18n_scope), 5],
              [t("inclusiveness.migrant_groups_invited.options.zero", scope: i18n_scope), 0]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.one')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.two')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.three')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.four')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.five')
            cultural_origins_participation: [
              [t("inclusiveness.cultural_origins_participation.options.one", scope: i18n_scope), 1],
              [t("inclusiveness.cultural_origins_participation.options.two", scope: i18n_scope), 2],
              [t("inclusiveness.cultural_origins_participation.options.three", scope: i18n_scope), 3],
              [t("inclusiveness.cultural_origins_participation.options.four", scope: i18n_scope), 4],
              [t("inclusiveness.cultural_origins_participation.options.five", scope: i18n_scope), 5]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_invited.options.five')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_invited.options.zero')
            functional_diversity_invited: [
              [t("inclusiveness.functional_diversity_invited.options.five", scope: i18n_scope), 5],
              [t("inclusiveness.functional_diversity_invited.options.zero", scope: i18n_scope), 0]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.one')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.two')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.three')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.four')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.five')
            functional_diversity_participation: [
              [t("inclusiveness.functional_diversity_participation.options.one", scope: i18n_scope), 1],
              [t("inclusiveness.functional_diversity_participation.options.two", scope: i18n_scope), 2],
              [t("inclusiveness.functional_diversity_participation.options.three", scope: i18n_scope), 3],
              [t("inclusiveness.functional_diversity_participation.options.four", scope: i18n_scope), 4],
              [t("inclusiveness.functional_diversity_participation.options.five", scope: i18n_scope), 5]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.one')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.two')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.three')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.four')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.five')
            relevance_percentage: [
              [t("relevance.relevance_percentage.options.one", scope: i18n_scope), 1],
              [t("relevance.relevance_percentage.options.two", scope: i18n_scope), 2],
              [t("relevance.relevance_percentage.options.three", scope: i18n_scope), 3],
              [t("relevance.relevance_percentage.options.four", scope: i18n_scope), 4],
              [t("relevance.relevance_percentage.options.five", scope: i18n_scope), 5]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.zero')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.one')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.two')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.three')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.four')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.five')
            citizen_influence_level: [
              [t("citizen_influence.citizen_influence_level.options.zero", scope: i18n_scope), 0,
               t("citizen_influence.citizen_influence_level.options.zero_description", scope: i18n_scope)],
              [t("citizen_influence.citizen_influence_level.options.one", scope: i18n_scope), 1,
               t("citizen_influence.citizen_influence_level.options.one_description", scope: i18n_scope)],
              [t("citizen_influence.citizen_influence_level.options.two", scope: i18n_scope), 2,
               t("citizen_influence.citizen_influence_level.options.two_description", scope: i18n_scope)],
              [t("citizen_influence.citizen_influence_level.options.three", scope: i18n_scope), 3,
               t("citizen_influence.citizen_influence_level.options.three_description", scope: i18n_scope)],
              [t("citizen_influence.citizen_influence_level.options.four", scope: i18n_scope), 4,
               t("citizen_influence.citizen_influence_level.options.four_description", scope: i18n_scope)],
              [t("citizen_influence.citizen_influence_level.options.five", scope: i18n_scope), 5,
               t("citizen_influence.citizen_influence_level.options.five_description", scope: i18n_scope)]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.one')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.two_five')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.five')
            languages_count: [
              [t("accessibility.languages_count.options.one", scope: i18n_scope), 1],
              [t("accessibility.languages_count.options.two_five", scope: i18n_scope), 2.5],
              [t("accessibility.languages_count.options.five", scope: i18n_scope), 5]
            ],
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.zero')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.two_five')
            # i18n-tasks-use t('decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.five')
            venue_accessibility: [
              [t("accessibility.venue_accessibility.options.zero", scope: i18n_scope), 0],
              [t("accessibility.venue_accessibility.options.two_five", scope: i18n_scope), 2.5],
              [t("accessibility.venue_accessibility.options.five", scope: i18n_scope), 5]
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
