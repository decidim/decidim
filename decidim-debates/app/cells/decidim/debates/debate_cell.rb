# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders the debate card for an instance of a Debate
    # the default size is the Medium Card (:m)
    class DebateCell < Decidim::ViewModel
      include DebateCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model
      end

      private

      def card_size
        "decidim/debates/debate_m"
      end
    end
  end
end
