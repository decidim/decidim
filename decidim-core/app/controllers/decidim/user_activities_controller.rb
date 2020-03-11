# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserActivitiesController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FilterResource

    helper Decidim::ResourceHelper
    helper_method :activities, :user

    private

    def user
      @user ||= current_organization.users.find_by(nickname: params[:nickname])
    end

    def activities
      @activities ||= paginate(
        ActivitySearch.new(
          organization: current_organization,
          user: user,
          resource_type: "all",
          resource_name: filter.resource_type
        ).run
      )
    end

    def default_filter_params
      { resource_type: nil }
    end
  end
end
