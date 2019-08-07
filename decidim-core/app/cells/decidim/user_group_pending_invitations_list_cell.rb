# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on user profiles.
  # Lists the invitations to user groups the given user has.
  class UserGroupPendingInvitationsListCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      return if invitations.empty?
      return unless own_profile?

      render :show
    end

    def invitations
      @invitations ||= Decidim::UserGroups::InvitedMemberships.for(model)
    end

    def own_profile?
      current_user == model
    end
  end
end
