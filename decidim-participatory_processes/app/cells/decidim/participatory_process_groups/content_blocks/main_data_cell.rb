# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include Decidim::SanitizeHelper

        delegate :title, :description, :group_url, :meta_scope, to: :resource

        private

        def extra_classes
          "participatory-space-group__content-block"
        end

        def title_text
          decidim_escape_translated(title)
        end

        def description_text
          decidim_sanitize_editor_admin translated_attribute(description)
        end

        def processes_count_item
          {
            icon: "grid-line",
            text: t(
              "decidim.participatory_process_groups.content_blocks.title.participatory_processes",
              count: cell("decidim/participatory_process_groups/content_blocks/related_processes", model).total_count
            )
          }
        end

        def external_link_item
          return if group_url.blank?

          {
            icon: "external-link-line",
            text: link_to(group_url_text, group_url, target: "_blank", rel: "noopener")
          }
        end

        def meta_scope_item
          return if (scope_text = translated_attribute(meta_scope)).blank?

          {
            icon: "globe-line",
            text: "<strong>#{t("decidim.participatory_process_groups.content_blocks.title.meta_scope")}</strong> #{scope_text}"
          }
        end

        def group_url_text
          group_uri.host + group_uri.path
        end

        def group_uri
          @group_uri = URI.parse(group_url)
        end
      end
    end
  end
end
