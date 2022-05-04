# frozen_string_literal: true

module Decidim
  module Debates
    # Custom helpers, scoped to the debates engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::RichTextEditorHelper
      include Decidim::EndorsableHelper
      include Decidim::FollowableHelper
      include Decidim::CheckBoxesTreeHelper

      # If the debate is official or the rich text editor is enabled on the
      # frontend, the debate description is considered as safe content.
      def safe_content?
        debate&.official? || rich_text_editor_in_public_views?
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_debate_description(debate)
        description = present(debate).description(strip_tags: !safe_content?, links: true)

        safe_content? ? decidim_sanitize_editor(description) : simple_format(description)
      end

      # Returns :text_area or :editor based on current_component settings.
      def text_editor_for_debate_description(form)
        text_editor_for(form, :description)
      end

      # Returns a TreeNode to be used in the list filters to filter debates by
      # its origin.
      def filter_origin_values
        origin_values = []
        origin_values << TreePoint.new("official", t("decidim.debates.debates.filters.official"))
        origin_values << TreePoint.new("participants", t("decidim.debates.debates.filters.participants"))
        origin_values << TreePoint.new("user_group", t("decidim.debates.debates.filters.user_groups")) if current_organization.user_groups_enabled?

        TreeNode.new(TreePoint.new("", t("decidim.debates.debates.filters.all")), origin_values)
      end

      # Options to filter Debates by activity.
      def activity_filter_values
        base = [
          ["all", t("decidim.debates.debates.filters.all")],
          ["my_debates", t("decidim.debates.debates.filters.my_debates")]
        ]
        base += [["commented", t("decidim.debates.debates.filters.commented")]]
        base
      end

      # Returns a TreeNode to be used in the list filters to filter debates by
      # its state.
      def filter_debates_state_values
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.debates.debates.filters.all")),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("open", t("decidim.debates.debates.filters.state_values.open")),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("closed", t("decidim.debates.debates.filters.state_values.closed"))
          ]
        )
      end
    end
  end
end
