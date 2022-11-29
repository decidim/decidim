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
        origin_keys = %w(official participants)
        origin_keys << "user_groups" if current_organization.user_groups_enabled?

        origin_values = origin_keys.map { |key| [key, filter_text_for(key, t(key, scope: "decidim.debates.debates.filters"))] }
        origin_values.prepend(["", all_filter_text])

        filter_tree_from_array(origin_values)
      end

      # Options to filter Debates by activity.
      def activity_filter_values
        %w(all my_debates commented).map { |k| [k, filter_text_for(k, t(k, scope: "decidim.debates.debates.filters"))] }
      end

      # Returns a TreeNode to be used in the list filters to filter debates by
      # its state.
      def filter_debates_state_values
        %w(open closed).map { |k| [k, filter_text_for(k, t(k, scope: "decidim.debates.debates.filters.state_values"))] }.prepend(
          ["all", all_filter_text]
        )
      end

      def all_filter_text
        filter_text_for("all", t("all", scope: "decidim.debates.debates.filters"))
      end
    end
  end
end
