# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders the debate card for an instance of a Debate
    # the default size is the Medium Card (:m)
    class DebateCell < Decidim::ViewModel
      include DebateCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/debates/debate_s"
        else
          "decidim/debates/debate_l"
        end
      end
    end
  end
end
