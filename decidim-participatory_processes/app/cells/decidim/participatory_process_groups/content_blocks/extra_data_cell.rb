# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        include Decidim::SanitizeHelper

        delegate :developer_group, :target, :participatory_scope, :participatory_structure, to: :resource

        private

        def extra_data_items
          [developer_group_item, target_item, participatory_scope_item, participatory_structure_item].compact
        end

        def developer_group_item
          return if (text = decidim_sanitize translated_attribute(developer_group)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.extra_data.developer_group"),
            icon: "question-line",
            text:
          }
        end

        def target_item
          return if (text = decidim_sanitize translated_attribute(target)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.extra_data.target"),
            icon: "question-line",
            text:
          }
        end

        def participatory_scope_item
          return if (text = decidim_sanitize translated_attribute(participatory_scope)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.extra_data.participatory_scope"),
            icon: "question-line",
            text:
          }
        end

        def participatory_structure_item
          return if (text = decidim_sanitize translated_attribute(participatory_structure)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.extra_data.participatory_structure"),
            icon: "question-line",
            text:
          }
        end

        def group_uri
          @group_uri = URI.parse(group_url)
        end

        def group_url_text
          group_uri.host + group_uri.path
        end

        def block_id
          "participatory_process_group-extra_data"
        end
      end
    end
  end
end
