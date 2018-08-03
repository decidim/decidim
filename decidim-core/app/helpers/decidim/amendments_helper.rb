# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper

    def amend_button_for(amendable)
      if amendable.amendable?
        cell "decidim/amendable/amend_button_card", amendable
      end
    end

    # Renders the emendations of a amendable resource that includes the
    # Amendable concern.
    #
    # amendable - The resource that has emendations.
    #
    # Returns Html grid of CardM.
    def amendments_for(amendable)
      if amendable.amendable?
        cell "decidim/amendable/amendments_list", amendable.emendations, context: {current_user: current_user}
      end
    end

    # Renders the state of an emendation
    #
    # emendation - The resource that is an emendation.
    #
    # Returns Html callout.
    def emendation_announcement_for(emendation)
      if emendation.emendation?
        cell "decidim/amendable/announcement", emendation
      end
    end

    # Renders the buttons to accept/reject an emendation (for amendable authors)
    #
    # emendation - The resource that is an emendation.
    #
    # Returns Html action button card
    def emendation_actions_for(emendation)
      if emendation.emendation? && emendation.amendable.authored_by?(current_user)
        cell "decidim/amendable/emendation_actions", emendation
      end
    end
  end
end
