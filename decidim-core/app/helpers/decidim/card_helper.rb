# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module CardHelper
    # Public: Returns a card given an instance of a Component.
    #
    # model - The component instance to generate the card for.
    # options - a Hash with options, for the size of the card
    #
    # Returns an HTML.
    def card_for(model, options = {})
      options = { context: { current_user: current_user } }.deep_merge(options)

      cell "decidim/card", model, options
    end
  end
end
