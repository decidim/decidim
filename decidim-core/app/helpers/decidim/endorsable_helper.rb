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

    # produces the path that should be POST to create an endorsement
    def path_to_create_endorsement(resource, user_group = nil)
      endorsements_path(resource_id: resource.to_gid.to_param,
                        user_group_id: user_group&.id,
                        authenticity_token: form_authenticity_token)
    end

    # Produces the path that should be DELETE to destroy an endorsement.
    def path_to_destroy_endorsement(resource, user_group = nil)
      endorsement_path(resource.to_gid.to_param,
                       user_group_id: user_group&.id,
                       authenticity_token: form_authenticity_token)
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
      render partial: "decidim/endorsements/identity", locals:
      { identity: presenter, selected: selected,
        http_method: http_method,
        create_url: path_to_create_endorsement(resource, user_group),
        destroy_url: path_to_destroy_endorsement(resource, user_group) }
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
  end
end
