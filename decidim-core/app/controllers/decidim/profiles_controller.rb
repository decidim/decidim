# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class ProfilesController < Decidim::ApplicationController
    helper Decidim::Messaging::ConversationHelper

    helper_method :profile_holder, :active_content

    before_action :ensure_profile_holder

    def show
      return redirect_to notifications_path if current_user == profile_holder
      @content_cell = "decidim/following"
    end

    def following
      @content_cell = "decidim/following"
      render :show
    end

    def followers
      @content_cell = "decidim/followers"
      render :show
    end

    def badges
      @content_cell = "decidim/badges"
      render :show
    end

    private

    def ensure_profile_holder
      raise ActionController::RoutingError unless profile_holder
    end

    def profile_holder
      @profile_holder ||= Decidim::User.find_by(
        nickname: params[:nickname],
        organization: current_organization
      ) || Decidim::UserGroup.find_by(
        nickname: params[:nickname],
        organization: current_organization
      )
    end
  end
end
