# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  # Lists the pending join requests of the given user group.
  class UserGroupPendingRequestsListCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      return if requests.empty?
      return unless current_user_is_manager?

      render :show
    end

    def requests
      @requests ||= Decidim::UserGroupMembership.includes(:user).where(user_group: model, role: "requested")
    end

    def current_user_is_manager?
      Decidim::UserGroups::ManageableUserGroups.for(current_user).include?(model)
    end
  end
end
