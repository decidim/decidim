# frozen_string_literal: true

module Decidim
  module Debates
    # Custom helpers, scoped to the debates engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::RichTextEditorHelper
      include Decidim::LikeableHelper
      include Decidim::FollowableHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::DateRangeHelper

      # If the debate is official or the rich text editor is enabled on the
      # frontend, the debate description is considered as safe content.
      def safe_content?
        rich_text_editor_in_public_views? || safe_content_admin?
      end

      # For admin entered content, the debate body can contain certain extra
      # tags, such as iframes.
      def safe_content_admin?
        debate&.official?
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_debate_description(debate)
        sanitized = render_sanitized_content(debate, :description)
        if safe_content?
          Decidim::ContentProcessor.render_without_format(sanitized).html_safe
        else
          Decidim::ContentProcessor.render(sanitized, "div")
        end
      end

      # Returns :text_area or :editor based on current_component settings.
      def text_editor_for_debate_description(form)
        text_editor_for(form, :description)
      end

      # Returns a TreeNode to be used in the list filters to filter debates by
      # its origin.
      def filter_origin_values
        origin_keys = %w(official participants)

        origin_values = origin_keys.map { |key| [key, t(key, scope: "decidim.debates.debates.filters")] }
        origin_values.prepend(["", all_filter_text])

        filter_tree_from_array(origin_values)
      end

      # Options to filter Debates by activity.
      def activity_filter_values
        %w(all my_debates commented).map { |k| [k, t(k, scope: "decidim.debates.debates.filters")] }
      end

      # Returns a TreeNode to be used in the list filters to filter debates by
      # its state.
      def filter_debates_state_values
        %w(open closed).map { |k| [k, t(k, scope: "decidim.debates.debates.filters.state_values")] }.prepend(
          ["all", all_filter_text]
        )
      end

      def all_filter_text
        t("all", scope: "decidim.debates.debates.filters")
      end

      def filter_sections
        @filter_sections ||= begin
          items = [{
            method: :with_any_state,
            collection: filter_debates_state_values,
            label: t("decidim.meetings.meetings.filters.date"),
            id: "date",
            type: :radio_buttons
          }]
          current_component.available_taxonomy_filters.each do |taxonomy_filter|
            items.append(method: :with_any_taxonomies,
                         collection: filter_taxonomy_values_for(taxonomy_filter),
                         label: decidim_sanitize_translated(taxonomy_filter.name),
                         id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}")
          end
          items.append(method: :with_any_origin, collection: filter_origin_values, label: t("decidim.debates.debates.filters.origin"), id: "origin")
          items.append(method: :activity, collection: activity_filter_values, label: t("decidim.debates.debates.filters.activity"), id: "activity") if current_user

          items.reject { |item| item[:collection].blank? }
        end
      end

      def search_variable = :search_text_cont

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.debates.name")
      end
    end
  end
end
