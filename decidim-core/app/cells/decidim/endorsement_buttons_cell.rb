# frozen_string_literal: true

module Decidim
  # This cell renders the endrosement button and the endorsements count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class EndorsementButtonsCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include EndorsableHelper

    delegate :current_user, to: :controller, prefix: false
    delegate :current_settings, to: :controller, prefix: false
    delegate :current_component, to: :controller, prefix: false
    delegate :allowed_to?, to: :controller, prefix: false

    def show
      render
    end

    # Renders a button to endorse the given +resource+.
    # To override the translation for both buttons: endorse and unendorse (use to be the name of the user/user_group).
    #
    # Parameters:
    #   resources  - The endorsable resource.
    #   btn_label  - A label to override the default button label (optional).
    #   user_group - The user_group on behalf of which the endorsement is being done (optional).
    def button(btn_label = nil, user_group = nil)
      create_endorsement_url = path_to_create_endorsement(resource, user_group)
      endorse_label = btn_label || t("decidim.endorsements_helper.endorsement_button.endorse")
      unendorse_label = btn_label || t("decidim.endorsements_helper.endorsement_button.already_endorsed")

      content_tag(:div, id: "resource-#{resource.id}-endorsement-button#{user_group&.id ? "-#{user_group.id}" : ""}") do
        if !current_user
          action_authorized_button_to(:endorse, endorse_label, create_endorsement_url, resource: resource, class: "button #{endorsement_button_classes} secondary")
        elsif resource.endorsed_by?(current_user, user_group)
          destroy_endorsement_url = path_to_destroy_endorsement(resource, user_group)
          action_authorized_button_to(:endorse, unendorse_label, destroy_endorsement_url, resource: resource, method: :delete, remote: true,
                                                                                          class: "button #{endorsement_button_classes} success", id: "endorsement_button")
        else
          action_authorized_button_to(:endorse, endorse_label, create_endorsement_url, resource: resource, remote: true,
                                                                                       class: "button #{endorsement_button_classes} secondary")
        end
      end
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

    def endorsement_identity_presenter(endorsement)
      if endorsement.user_group
        Decidim::UserGroupPresenter.new(endorsement.user_group)
      else
        Decidim::UserPresenter.new(endorsement.author)
      end
    end

    #-----------------------------------------------------

    private

    #-----------------------------------------------------

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
