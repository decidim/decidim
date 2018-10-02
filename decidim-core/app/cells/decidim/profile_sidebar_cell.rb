# frozen_string_literal: true

module Decidim
  class ProfileSidebarCell < Decidim::ProfileCell
    include Decidim::Messaging::ConversationHelper
    include Decidim::IconHelper
    include Decidim::ViewHooksHelper
    include Decidim::ApplicationHelper

    helper_method :profile_user, :logged_in?, :current_user

    delegate :user_signed_in?, to: :controller

    def show
      render :show
    end

    private

    def logged_in?
      current_user.present?
    end

    def profile_user
      @profile_user ||= present(model)
    end

    def can_contact_user?
      !current_user || (current_user && current_user != model)
    end
  end
end
