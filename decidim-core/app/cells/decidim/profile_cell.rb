# frozen_string_literal: true

module Decidim
  class ProfileCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::UserProfileHelper
    include Decidim::AriaSelectedLinkToHelper
    include ActiveLinkTo

    delegate :current_organization, :current_user, to: :controller

    def show
      render :show
    end

    def user
      model
    end

    def content_cell
      context[:content_cell]
    end

    def active_content
      context[:active_content]
    end

    def own_profile?
      current_user && current_user == user
    end
  end
end
