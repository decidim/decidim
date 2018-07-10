# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper

    def amend_button_for(amendable)
      if amendable.component.settings.amendments_enabled?
        cell "decidim/amend_button_card", amendable, context: { current_user: current_user }
      end
    end

    # Renders a the amendments of a amendable model that includes the
    # Amendable concern.
    #
    # amendable - The model to render the amendments from.
    #
    # Returns nothing.
    # def amendments_for(amendable)
    #   cell "decidim/amendments", amendable, context: { current_user: current_user }
    # end
  end
end
