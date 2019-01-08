# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserTimelineController < Decidim::ApplicationController
    include Paginable
    include UserGroups

    helper Decidim::ResourceHelper
    helper_method :activities, :user

    def index
      raise ActionController::RoutingError, "Not Found" if current_user != user
    end

    private

    def user
      @user ||= Decidim::User.find_by(
        organization: current_organization,
        nickname: params[:nickname]
      )
    end

    def activities
      @activities ||= paginate(
        ActivitySearch.new(
          organization: current_organization,
          resource_type: "all",
          scopes: current_user.interested_scopes,
          follows: follows
        ).run
      )
    end

    def follows
      @follows ||= Decidim::Follow.where(user: user)
    end
  end
end
