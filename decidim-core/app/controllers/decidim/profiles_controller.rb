# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class ProfilesController < Decidim::ApplicationController
    helper Decidim::Messaging::ConversationHelper

    helper_method :user

    def show; end

    private

    def user
      @user ||= Decidim::User.find_by!(
        nickname: params[:nickname],
        organization: current_organization
      )
    end
  end
end
