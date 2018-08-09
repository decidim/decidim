# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper
    def amend_button_for(amendable)
      cell "decidim/amendable/amend_button_card", amendable if amendable.amendable?
    end

    # Renders the emendations of a amendable resource that includes the
    # Amendable concern.
    #
    # amendable - The resource that has emendations.
    #
    # Returns Html grid of CardM.
    def amendments_for(amendable)
      cell "decidim/amendable/amendments_list", amendable.emendations, context: { current_user: current_user } if amendable.amendable?
    end

    def amenders_for(amendable)
      amenders = amendable.amendments.map{ |amendment| present(amendment.amender) }.uniq
    end

    def amenders_list_for(amendable)
      cell "decidim/amendable/amenders_list", amenders_for(amendable), context: { current_user: current_user } if amendable.amendable?
    end

    # Renders the state of an emendation
    #
    # emendation - The resource that is an emendation.
    #
    # Returns Html callout.
    def emendation_announcement_for(emendation)
      cell "decidim/amendable/announcement", emendation if emendation.emendation?
    end

    # Renders the buttons to accept/reject an emendation (for amendable authors)
    #
    # emendation - The resource that is an emendation.
    #
    # Returns Html action button card
    def emendation_actions_for(emendation_form)
      cell "decidim/amendable/emendation_actions", emendation_form if emendation_form.emendation.emendation? && emendation_form.amendable.authored_by?(current_user)
    end

    def user_group_select_field(form, name)
      selected = @form.user_group_id.presence
      form.select(
        name,
        current_user.user_groups.verified.map { |g| [g.name, g.id] },
        selected: selected,
        include_blank: current_user.name
      )
    end
  end
end
