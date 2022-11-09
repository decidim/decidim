# frozen_string_literal: true

module Decidim
  # This cell renders the endrosement button and the endorsements count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class EndorsementButtonsCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include EndorsableHelper
    include ResourceHelper
    include Decidim::SanitizeHelper

    delegate :current_user, to: :controller, prefix: false
    delegate :current_settings, to: :controller, prefix: false
    delegate :current_component, to: :controller, prefix: false
    delegate :allowed_to?, to: :controller, prefix: false

    def show
      render
    end

    # Renders the "Endorse" button.
    # Contains all the logic about how the button should be rendered
    # and which actions the button must trigger.
    #
    # It takes into account:
    # - if endorsements are enabled
    # - if users are logged in
    # - if users can endorse with many identities (of their user_groups)
    # - if users require verification
    def render_endorsements_button
      if endorsements_blocked_or_user_can_not_participate?
        render_disabled_endorsements_button
      elsif !current_user
        render_user_login_button
      elsif current_user_and_allowed?
        # Remove identities_cabin
        if user_has_verified_groups?
          render "select_identity_button"
        else
          render_user_identity_endorse_button
        end
      else # has current_user but is not allowed
        render_verification_modal
      end
    end

    # Renders the counter of endorsements that appears in m-cards.
    # deprecated
    def render_endorsements_count
      content = icon("bullhorn", class: "icon--small", aria_label: t("decidim.endorsable.endorsements_count"), role: "img")
      content += resource.endorsements_count.to_s
      html_class = "button small compact button--shadow secondary"
      html_class += " active" if fully_endorsed?(resource, current_user)
      tag_params = { id: "resource-#{resource.id}-endorsements-count", class: html_class }
      if resource.endorsements_count.positive?
        link_to "#list-of-endorsements", tag_params do
          content
        end
      else
        content_tag(:div, tag_params) do
          content
        end
      end
    end

    # Renders the endorsements button but disabled.
    # To be used to let the user know that endorsements are enabled but are blocked or cant participate.
    def render_disabled_endorsements_button
      content_tag :span, class: "#{card_button_html_class} #{endorsement_button_classes(from_resourcess_list: false)} disabled", disabled: true, title: endorse_translated do
        endorse_translated + render_screen_reader_context_title
      end
    end

    # deprecated
    def render_screen_reader_context_title
      content_tag :span, class: "show-for-sr" do
        decidim_html_escape(resource_title(resource))
      end
    end

    # Returns the css classes used for proposal endorsement button in both proposals list and show pages
    #
    # from_resourcess_list - A boolean to indicate if the template is rendered from the list page of the resource.
    #
    # Returns a string with the value of the css classes.
    def endorsement_button_classes(from_resourcess_list: false)
      return "small" if from_resourcess_list

      "button small compact light button--sc expanded secondary"
    end

    def card_button_html_class
      "card__button button"
    end

    # Renders a button to endorse the given +resource+ with the personal identity of the user.
    # To override the translation for both buttons: endorse and unendorse (use to be the name of the user/user_group).
    #
    # This button may have different behaviours:
    # - If the user is not logged in, the button will open the signin/signup popup.
    # - If the user is logged in, and the resource has not been endorsed, the button will allow to endorse.
    # - If the user is logged in, and the resource has already been endorsed, the button will allow to UNendorse.
    #
    # Parameters:
    #   resources  - The endorsable resource.
    def render_user_identity_endorse_button
      content_tag(:div, id: "resource-#{resource.id}-endorsement-button") do
        if !current_user
          render_user_login_button
        elsif resource.endorsed_by?(current_user)
          unendorse_label = t("decidim.endorsement_buttons_cell.already_endorsed")
          destroy_endorsement_url = path_to_destroy_endorsement(resource)
          action_authorized_button_to(
            :endorse,
            destroy_endorsement_url,
            resource:,
            method: :delete,
            remote: true,
            class: "button #{endorsement_button_classes} active",
            id: "endorsement_button"
          ) do
            unendorse_label + render_screen_reader_context_title
          end
        else
          action_authorized_button_to(
            :endorse,
            path_to_create_endorsement(resource),
            resource:,
            remote: true,
            class: "button #{endorsement_button_classes}",
            id: "endorsement_button"
          ) do
            endorse_translated + render_screen_reader_context_title
          end
        end
      end
    end

    # The resource being un/endorsed is the Cell's model.
    def resource
      model
    end

    # deprecated
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

    def render_user_login_button
      action_authorized_button_to(:endorse,
                                  path_to_create_endorsement(resource),
                                  resource:,
                                  class: "button #{endorsement_button_classes}") do
        endorse_translated + render_screen_reader_context_title
      end
    end

    def render_verification_modal
      button_to(endorsement_path(resource),
                data: { open: "authorizationModal", "open-url": modal_path(:endorse, resource) },
                class: "#{card_button_html_class} #{endorsement_button_classes(from_resourcess_list: false)}") do
        endorse_translated + render_screen_reader_context_title
      end
    end

    def endorsements_blocked_or_user_can_not_participate?
      current_settings.endorsements_blocked? || !current_component.participatory_space.can_participate?(current_user)
    end

    def current_user_and_allowed?
      current_user && allowed_to?(:create, :endorsement, resource:)
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
