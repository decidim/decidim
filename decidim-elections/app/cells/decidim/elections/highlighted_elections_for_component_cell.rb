# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Elections
    # This cell renders the highlighted elections for a given participatory
    # space. It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedElectionsForComponentCell < Decidim::ViewModel
      include ElectionCellsHelper
      include Decidim::ComponentPathHelper
      include Decidim::CardHelper

      def show
        render unless items_blank?
      end

      def items_blank?
        elections_count.zero?
      end

      private

      def elections_count
        @elections_count ||= elections.size
      end

      def elections
        @elections ||= Decidim::Elections::Election.where(component: model).published
      end

      def single_component?
        @single_component ||= model.is_a?(Decidim::Component)
      end

      def see_all_path
        @see_all_path ||= options[:see_all_path] || (single_component? && main_component_path(model))
      end

      def cache_hash
        hash = []
        hash << "decidim/elections/highlighted_elections_for_component"
        hash << elections.cache_key_with_version
        hash << I18n.locale.to_s
        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
