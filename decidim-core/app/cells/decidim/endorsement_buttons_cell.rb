# frozen_string_literal: true

module Decidim
  # This cell renders the like button and the likes count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class EndorsementButtonsCell < Decidim::ViewModel
    include CellsHelper
    include EndorsableHelper
    include ResourceHelper

    # Renders the "Like" button.
    # Contains all the logic about how the button should be rendered
    # and which actions the button must trigger.
    #
    # It takes into account:
    # - if likes are enabled
    # - if users are logged in
    # - if users require verification
    def show
      return render :disabled_endorsements if endorsements_blocked?
      return render unless current_user
      return render :disabled_endorsements if user_can_not_participate?
      return render :verification_modal unless endorse_allowed?

      render
    end

    def button_classes
      "button button__sm button__transparent-secondary"
    end

    # The resource being un/liked is the Cell's model.
    def resource
      model
    end

    # produce the path to likes from the engine routes as the cell does not have access to routes
    def endorsements_path(*)
      decidim.endorsements_path(*)
    end

    # produce the path to an like from the engine routes as the cell does not have access to routes
    def endorsement_path(*)
      decidim.endorsement_path(*)
    end

    def button_content
      render
    end

    private

    def endorsements_blocked?
      current_settings.endorsements_blocked?
    end

    def user_can_not_participate?
      !current_component.participatory_space.can_participate?(current_user)
    end

    def endorse_allowed?
      allowed_to?(:create, :like, resource:)
    end

    def endorse_translated
      @endorse_translated ||= resource.endorsed_by?(current_user) ? t("decidim.endorsement_buttons_cell.already_endorsed") : t("decidim.endorsement_buttons_cell.like")
    end

    def endorse_icon
      @endorse_icon ||= resource_type_icon(resource.endorsed_by?(current_user) ? "dislike" : "like")
    end

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
