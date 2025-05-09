# frozen_string_literal: true

module Decidim
  # A Helper for views with Likable resources.
  module EndorsableHelper
    # Public: Checks if like are enabled in this step.
    #
    # Returns true if enabled, false otherwise.
    def endorsements_enabled?
      current_settings.endorsements_enabled
    end

    # Public: Checks if likes are blocked in this step.
    #
    # Returns true if blocked, false otherwise.
    def endorsements_blocked?
      current_settings.endorsements_blocked
    end

    # Public: Checks if the current user is allowed to like in this step.
    #
    # Returns true if the current user can like, false otherwise.
    def current_user_can_endorse?
      current_user && endorsements_enabled? && !endorsements_blocked?
    end

    # Public: Checks if the card for likes should be rendered.
    #
    # Returns true if the likes card should be rendered, false otherwise.
    def show_endorsements_card?
      endorsements_enabled?
    end

    # produces the path that should be POST to create an like
    def path_to_create_endorsement(resource)
      endorsements_path(resource_id: resource.to_gid.to_param,
                        authenticity_token: form_authenticity_token)
    end

    # Produces the path that should be DELETE to destroy an like.
    def path_to_destroy_endorsement(resource)
      endorsement_path(resource.to_gid.to_param,
                       authenticity_token: form_authenticity_token)
    end
  end
end
