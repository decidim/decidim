# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Sortitions
    # This cell renders a sortition with its L-size card.
    class SortitionLCell < Decidim::CardLCell
      include Decidim::Sortitions::Engine.routes.url_helpers

      private

      def has_author?
        false
      end

      def has_state?
        true
      end

      def metadata_cell
        "decidim/sortitions/sortition_metadata"
      end
    end
  end
end
