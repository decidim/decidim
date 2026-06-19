# frozen_string_literal: true

module Decidim
  module Blogs
    # Custom helpers, scoped to the blogs engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include SanitizeHelper
      include Decidim::Blogs::PostsHelper
      include ::Decidim::LikeableHelper
      include ::Decidim::FollowableHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::CheckBoxesTreeHelper

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.blogs.name")
      end

      def filter_sections
        @filter_sections ||= []

        current_component.available_taxonomy_filters.each do |taxonomy_filter|
          @filter_sections << {
            method: :with_any_taxonomies,
            name: "[with_any_taxonomies][#{taxonomy_filter.root_taxonomy_id}]",
            collection: filter_taxonomy_values_for(taxonomy_filter),
            label: decidim_sanitize_translated(taxonomy_filter.name),
            id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}"
          }
        end

        @filter_sections
      end

      def search_variable = :search_text_cont
    end
  end
end
