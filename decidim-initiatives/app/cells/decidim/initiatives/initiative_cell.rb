# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the process card for an instance of an Initiative
    # the default size is the Medium Card (:m)
    class InitiativeCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/initiatives/initiative_s"
        else
          "decidim/initiatives/initiative_g"
        end
      end
    end
  end
end
