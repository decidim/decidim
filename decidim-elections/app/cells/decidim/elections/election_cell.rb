# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the election card for an instance of an election
    # the default size is the Medium Card (:m)
    class ElectionCell < Decidim::ViewModel
      include ElectionCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/elections/election_m"
      end
    end
  end
end
