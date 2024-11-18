# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the highlighted results for a given participatory
    # space. It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedResultsCell < Decidim::ViewModel
      private

      def published_components
        Decidim::Component
          .where(
            participatory_space: model,
            manifest_name: :accountability
          )
          .published
      end
    end
  end
end
