# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the election card for an instance of an election
    # the default size is the Search Card (:s)
    class ElectionCell < Decidim::ViewModel
      include ElectionCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/elections/election_s"
        else
          "decidim/elections/election_g"
        end
      end
    end
  end
end
