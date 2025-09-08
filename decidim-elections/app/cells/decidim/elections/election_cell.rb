# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/elections/election_s"
        when :g
          "decidim/elections/election_g"
        else
          "decidim/elections/election_l"
        end
      end
    end
  end
end
