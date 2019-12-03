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
  end
end
