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

        def settings_options
          {
            migrant_groups_invited: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.migrant_groups_invited.options.five"), 5],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.migrant_groups_invited.options.zero"), 0]
            ],
            cultural_origins_participation: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.one"), 1],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.two"), 2],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.three"), 3],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.four"), 4],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.cultural_origins_participation.options.five"), 5]
            ],
            functional_diversity_invited: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_invited.options.five"), 5],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_invited.options.zero"), 0]
            ],
            functional_diversity_participation: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.one"), 1],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.two"), 2],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.three"), 3],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.four"), 4],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.inclusiveness.functional_diversity_participation.options.five"), 5]
            ],
            relevance_percentage: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.one"), 1],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.two"), 2],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.three"), 3],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.four"), 4],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.relevance.relevance_percentage.options.five"), 5]
            ],
            citizen_influence_level: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.zero"), 0,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.zero_description")],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.one"), 1,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.one_description")],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.two"), 2,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.two_description")],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.three"), 3,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.three_description")],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.four"), 4,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.four_description")],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.five"), 5,
               t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.citizen_influence.citizen_influence_level.options.five_description")]
            ],
            languages_count: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.one"), 1],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.two_five"), 2.5],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.languages_count.options.five"), 5]
            ],
            venue_accessibility: [
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.zero"), 0],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.two_five"), 2.5],
              [t("decidim.participatory_processes.admin.content_blocks.democratic_quality_stats_settings_form.accessibility.venue_accessibility.options.five"), 5]
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
