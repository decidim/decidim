# frozen_string_literal: true

module Decidim
  # This cell renders the endrosement button and the endorsements count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class RedesignedEndorsementButtonsCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include EndorsableHelper
    include ResourceHelper
    include Decidim::SanitizeHelper

    delegate :current_user, to: :controller, prefix: false
    delegate :current_settings, to: :controller, prefix: false
    delegate :current_component, to: :controller, prefix: false
    delegate :allowed_to?, to: :controller, prefix: false

    # Renders the "Endorse" button.
    # Contains all the logic about how the button should be rendered
    # and which actions the button must trigger.
    #
    # It takes into account:
    # - if endorsements are enabled
    # - if users are logged in
    # - if users can endorse with many identities (of their user_groups)
    # - if users require verification
    def show
      return render :disabled_endorsements if endorsements_blocked_or_user_can_not_participate?
      return render unless current_user
      return render :user_verification_button unless endorse_allowed?
      return render :select_identity_button if user_has_verified_groups?

      render
    end

    def button_classes
      "button button__sm button__transparent-secondary"
    end

    # The resource being un/endorsed is the Cell's model.
    def resource
      model
    end

    def reveal_identities_url
      decidim.identities_endorsement_path(resource.to_gid.to_param)
    end

    # produce the path to endorsements from the engine routes as the cell doesn't have access to routes
    def endorsements_path(*args)
      decidim.endorsements_path(*args)
    end

    # produce the path to an endorsement from the engine routes as the cell doesn't have access to routes
    def endorsement_path(*args)
      decidim.endorsement_path(*args)
    end

    private

    def endorsements_blocked_or_user_can_not_participate?
      current_settings.endorsements_blocked? || !current_component.participatory_space.can_participate?(current_user)
    end

    def endorse_allowed?
      allowed_to?(:create, :endorsement, resource: resource)
    end

    def user_has_verified_groups?
      current_user && Decidim::UserGroups::ManageableUserGroups.for(current_user).verified.any?
    end

    def endorse_translated
      @endorse_translated ||= t("decidim.endorsement_buttons_cell.endorse")
    end

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
