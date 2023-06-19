# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedParticipatorySpacesCell < BaseCell
      include Decidim::CardHelper

      SECTION_CLASS = "home__section"

      def show
        render if highlighted_spaces.any?
      end

      def limited_highlighted_spaces
        return highlighted_spaces if max_results.blank?

        highlighted_spaces.limit(max_results)
      end

      def highlighted_spaces
        raise "#{self.class.name} is expected to implement #highlighted_spaces"
      end

      def i18n_scope; end

      def all_path; end

      def max_results; end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(highlighted_spaces.map(&:cache_key_with_version))
        hash.join(Decidim.cache_key_separator)
      end

      def section_class = SECTION_CLASS
    end
  end
end
