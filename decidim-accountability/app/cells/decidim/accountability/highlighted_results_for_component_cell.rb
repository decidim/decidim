# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the highlighted results for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedResultsForComponentCell < Decidim::ViewModel
      include ActiveSupport::NumberHelper
      include Decidim::Accountability::ApplicationHelper
      include Decidim::ComponentPathHelper
      include Decidim::LayoutHelper
      include Cell::ViewModel::Partial

      def show
        render unless results_count.zero?
      end

      private

      def results
        @results ||= Decidim::Accountability::Result.where(component: model).order_randomly(rand * 2 - 1)
      end

      def results_to_render
        @results_to_render ||= results.includes(:component, :status).limit(4)
      end

      def results_count
        @results_count ||= results.count
      end

      def cache_hash
        hash = []
        hash << "decidim/Accountability/highlighted_results_for_component"
        hash << results.cache_key_with_version
        hash << I18n.locale.to_s
        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
