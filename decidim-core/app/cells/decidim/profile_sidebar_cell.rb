# frozen_string_literal: true

module Decidim
  class ProfileSidebarCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::ViewHooksHelper
    include Decidim::Core::Engine.routes.url_helpers

    helper_method :profile_user, :own_profile?, :logged_in?, :current_user

    delegate :current_organization, :current_user, to: :controller

    def show
      render :show
    end

    def user
      model
    end

    private

    def own_profile?
      current_user && current_user == user
    end

    def logged_in?
      current_user.present?
    end

    def profile_user
      @profile_user ||= Decidim::UserPresenter.new(model)
    end

    def can_contact_user?
      !current_user || (current_user && current_user != model)
    end
  end
end
