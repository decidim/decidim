# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class ProfilesController < Decidim::ApplicationController
    helper Decidim::Messaging::ConversationHelper

    helper_method :user, :active_content

    def show
      return redirect_to profile_notifications_path(nickname: params[:nickname]) if current_user == user && params[:active].blank?
      return redirect_to profile_path(nickname: params[:nickname]) if current_user != user && params[:active] == "notifications"
    end

    private

    def user
      @user ||= Decidim::User.find_by!(
        nickname: params[:nickname],
        organization: current_organization
      )
    end

    def active_content
      return "following" if current_user != user && params[:active].blank?
      params[:active].presence
    end
  end
end
