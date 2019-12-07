# frozen_string_literal: true

module Decidim
  # A Helper for views with Endorsable resources.
  module EndorsableHelper
    #
    # Public: Checks if the given resource has been endorsed by all identities of the user.
    #
    # @param resource: The resource from which endorsements will be checked against.
    # @param user:     The user whose identities and endorsements  will be checked against.
    #
    def fully_endorsed?(resource, user)
      return false unless user

      user_group_endorsements = Decidim::UserGroups::ManageableUserGroups.for(user).verified.all? { |user_group| resource.endorsed_by?(user, user_group) }

      user_group_endorsements && resource.endorsed_by?(user)
    end

    # Public: Checks if endorsement are enabled in this step.
    #
    # Returns true if enabled, false otherwise.
    def endorsements_enabled?
      current_settings.endorsements_enabled
    end

    # Public: Checks if endorsements are blocked in this step.
    #
    # Returns true if blocked, false otherwise.
    def endorsements_blocked?
      current_settings.endorsements_blocked
    end

    # Public: Checks if the current user is allowed to endorse in this step.
    #
    # Returns true if the current user can endorse, false otherwise.
    def current_user_can_endorse?
      current_user && endorsements_enabled? && !endorsements_blocked?
    end

    # Public: Checks if the card for endorsements should be rendered.
    #
    # Returns true if the endorsements card should be rendered, false otherwise.
    def show_endorsements_card?
      endorsements_enabled?
    end

    # Renders an identity for endorsement.
    #
    # Parameters:
    #   resources  - The endorsable resource.
    #   user       - The user that is endorsing at the end (mandatory).
    #   user_group - The user_group on behalf of which the endorsement is being done (optional).
    def render_endorsement_identity(resource, user, user_group = nil)
      presenter = if user_group
                    Decidim::UserGroupPresenter.new(user_group)
                  else
                    Decidim::UserPresenter.new(user)
                  end
      selected = resource.endorsed_by?(user, user_group)
      http_method = selected ? :delete : :post
      create_url = endorsements_path(resource_id: resource.to_gid.to_param,
                                     user_group_id: user_group&.id,
                                     authenticity_token: form_authenticity_token)
      destroy_url = endorsement_path(resource.to_gid.to_param,
                                     user_group_id: user_group&.id,
                                     authenticity_token: form_authenticity_token)
      render partial: "decidim/endorsements/identity", locals:
      { identity: presenter, selected: selected,
        http_method: http_method,
        create_url: create_url,
        destroy_url: destroy_url }
    end

    # Renders the counter of endorsements that appears in card at show Propoal.
    def render_endorsements_count_card_part(resource)
      content = icon("bullhorn", class: "icon--small", aria_label: "Endorsements", role: "img")
      content += resource.endorsements_count.to_s
      html_class = "button small compact light button--sc button--shadow "
      html_class += fully_endorsed?(resource, current_user) ? "success" : "secondary"
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

    def render_endorsements_button_card_part(resource, html_class = nil)
      endorse_translated = t("decidim.endorsement_cell.render_endorsements_button_card_part.endorse")
      html_class = "card__button button" if html_class.blank?
      if current_settings.endorsements_blocked? || !current_component.participatory_space.can_participate?(current_user)
        content_tag :span, endorse_translated, class: "#{html_class} #{endorsement_button_classes(false)} disabled", disabled: true, title: endorse_translated
      elsif current_user && allowed_to?(:create, :endorsement, resource: resource)
        render "endorsement_identities_cabin"
      elsif current_user
        button_to(endorse_translated, proposal_path(resource),
                  data: { open: "authorizationModal", "open-url": modal_path(:endorse, resource) },
                  class: "#{html_class} #{endorsement_button_classes(false)} secondary")
      else
        action_authorized_button_to :endorse, endorse_translated, "", resource: resource, class: "#{html_class} #{endorsement_button_classes(false)} secondary"
      end
    end

    # Renders a button to endorse the given +resource+.
    # To override the translation for both buttons: endorse and unendorse (use to be the name of the user/user_group).
    #
    # Parameters:
    #   resources  - The endorsable resource.
    #   btn_label  - A label to override the default button label (optional).
    #   user_group - The user_group on behalf of which the endorsement is being done (optional).
    def endorsement_button(resource, btn_label = nil, user_group = nil)
      current_endorsement_url = endorsement_path(
        resource.to_gid.to_param,
        user_group_id: user_group&.id
      )
      endorse_label = btn_label || t("decidim.endorsements_helper.endorsement_button.endorse")
      unendorse_label = btn_label || t("decidim.endorsements_helper.endorsement_button.already_endorsed")

      render partial: "decidim/endorsements/endorsement_button", locals: { resource: resource,
                                                                           user_group: user_group,
                                                                           current_endorsement_url: current_endorsement_url,
                                                                           endorse_label: endorse_label, unendorse_label: unendorse_label }
    end

    # Returns the css classes used for proposal endorsement button in both proposals list and show pages
    #
    # from_resourcess_list - A boolean to indicate if the template is rendered from the list page of the resource.
    #
    # Returns a string with the value of the css classes.
    def endorsement_button_classes(from_resourcess_list = false)
      return "small" if from_resourcess_list

      "small compact light button--sc expanded"
    end
  end
end
