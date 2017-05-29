# frozen_string_literal: true

require_dependency "decidim/application_controller"

module Decidim
  # The controller to handle managing the current user's
  # UserGroups.
  class OwnUserGroupsController < ApplicationController
    include Decidim::UserProfile

    def index
      @user_groups = current_user.user_groups
    end
  end
end
