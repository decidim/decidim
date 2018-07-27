# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper

    def amend_button_for(amendable)
      if amendable.amendable?
        cell "decidim/amendable/amend_button_card", amendable
      end
    end

    # Renders a the amendments of a amendable model that includes the
    # Amendable concern.
    #
    # amendable - The model to render the amendments from.
    #
    # Returns nothing.
    def amends_for(amendable)
      if amendable.amendable?
        cell "decidim/amendable/amendments_list", amendable.emendations
      end
    end

    def emendation_announcement_for(amendable)
      if amendable.emendation?
        cell "decidim/amendable/announcement", amendable
      end
    end

    def emendation_actions_for(amendable)
      if amendable.emendation? && amendable.authored_by?(current_user)
        cell "decidim/amendable/emendation_actions", amendable
      end
    end
  end
end
