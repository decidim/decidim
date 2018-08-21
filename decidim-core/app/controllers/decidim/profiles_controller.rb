# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class ProfilesController < Decidim::ApplicationController
    helper Decidim::Messaging::ConversationHelper

    helper_method :user, :active_content

    def show
      return redirect_to notifications_path if current_user == user
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

    def user
      @user ||= Decidim::User.find_by!(
        nickname: params[:nickname],
        organization: current_organization
      )
    end
  end
end
