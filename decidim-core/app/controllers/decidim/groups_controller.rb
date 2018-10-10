# frozen_string_literal: true

module Decidim
  # The controller to handle user groups creation
  class GroupsController < Decidim::ApplicationController
    include FormFactory

    def new
      enforce_permission_to :create, :user_group, current_user: current_user
      @form = form(UserGroupForm).instance
    end

    def create
      enforce_permission_to :create, :user_group, current_user: current_user
    end
  end
end
