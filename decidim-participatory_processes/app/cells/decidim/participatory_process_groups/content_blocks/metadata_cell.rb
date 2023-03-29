# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class MetadataCell < Decidim::ContentBlocks::ParticipatorySpaceMetadataCell
        include Decidim::SanitizeHelper
        include Decidim::TwitterSearchHelper

        delegate :hashtag, :group_url, :meta_scope, :developer_group, :target, :participatory_scope, :participatory_structure, to: :resource

        private

        def metadata_items
          [processes_count_item, external_link_item, hashtag_item, meta_scope_item, developer_group_item, target_item, participatory_scope_item, participatory_structure_item]
        end

        def processes_count_item
          {
            title: t("processes_count", scope: "decidim.statistics"),
            icon: "question-line",
            text: cell("decidim/participatory_process_groups/content_blocks/related_processes", model).total_count
          }
        end

        def external_link_item
          return if group_url.blank?

          {
            title: t("group_url", scope: "activemodel.attributes.participatory_process_group"),
            icon: "question-line",
            text: link_to(group_url_text, group_url, target: "_blank", rel: "noopener")
          }
        end

        def hashtag_item
          return if hashtag_text.blank?

          {
            title: t("hashtag", scope: "activemodel.attributes.participatory_process_group"),
            icon: "hashtag",
            text: link_to("##{hashtag_text}", twitter_hashtag_url(hashtag_text), target: "_blank", rel: "noopener")
          }
        end

        def meta_scope_item
          return if (text = translated_attribute(meta_scope)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.metadata.meta_scope"),
            icon: "question-line",
            text:
          }
        end

        def developer_group_item
          return if (text = decidim_sanitize translated_attribute(developer_group)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.metadata.developer_group"),
            icon: "question-line",
            text:
          }
        end

        def target_item
          return if (text = decidim_sanitize translated_attribute(target)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.metadata.target"),
            icon: "question-line",
            text:
          }
        end

        def participatory_scope_item
          return if (text = decidim_sanitize translated_attribute(participatory_scope)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.metadata.participatory_scope"),
            icon: "question-line",
            text:
          }
        end

        def participatory_structure_item
          return if (text = decidim_sanitize translated_attribute(participatory_structure)).blank?

          {
            title: t("decidim.participatory_process_groups.content_blocks.metadata.participatory_structure"),
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

        def hashtag_text
          @hashtag_text ||= decidim_html_escape(hashtag || "")
        end

        def block_id
          "participatory_process_group-metadata"
        end
      end
    end
  end
end
