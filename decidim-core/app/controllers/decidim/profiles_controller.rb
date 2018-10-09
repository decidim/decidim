# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class ProfilesController < Decidim::ApplicationController
    helper Decidim::Messaging::ConversationHelper

    helper_method :profile_holder, :active_content

    before_action :ensure_profile_holder
    before_action :ensure_profile_holder_is_a_group, only: [:members]
    before_action :ensure_profile_holder_is_a_user, only: [:groups, :badges, :following]

    def show
      return redirect_to notifications_path if current_user == profile_holder
      return redirect_to profile_members_path if profile_holder.is_a?(Decidim::UserGroup)
      redirect_to profile_following_path
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

    def groups
      @content_cell = "decidim/groups"
      render :show
    end

    def members
      @content_cell = "decidim/members"
      render :show
    end

    private

    def ensure_profile_holder_is_a_group
      raise ActionController::RoutingError, "No user group with the given nickname" unless profile_holder.is_a?(Decidim::UserGroup)
    end

    def ensure_profile_holder_is_a_user
      raise ActionController::RoutingError, "No user with the given nickname" unless profile_holder.is_a?(Decidim::User)
    end

    def ensure_profile_holder
      raise ActionController::RoutingError, "No user or user group with the given nickname" unless profile_holder
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
