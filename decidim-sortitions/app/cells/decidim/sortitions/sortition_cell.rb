# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Sortitions
    # This cell renders the card for an instance of a Sortition
    # the default size is the Medium Card (:m)
    class SortitionCell < Decidim::ViewModel
      def show
        cell card_size, model, @options
      end

      private

      def card_size
        "decidim/sortitions/sortition_m"
      end
    end
  end
end
