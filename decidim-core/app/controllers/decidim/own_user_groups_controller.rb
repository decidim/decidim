# frozen_string_literal: true

module Decidim
  # The controller to handle managing the current user's
  # UserGroups.
  class OwnUserGroupsController < Decidim::ApplicationController
    include Decidim::UserProfile

    def index
      @user_groups = current_user.user_groups
    end
  end
end
