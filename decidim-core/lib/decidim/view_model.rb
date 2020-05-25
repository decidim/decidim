# frozen_string_literal: true

module Decidim
  autoload :ActionAuthorizationHelper, "decidim/action_authorization_helper"
  autoload :ResourceHelper, "decidim/resource_helper"

  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::ScopesHelper
    include ActionController::Helpers
    include Decidim::ActionAuthorization
    include Decidim::ActionAuthorizationHelper
    include Decidim::ReplaceButtonsHelper

    delegate :current_organization, to: :controller

    def current_user
      context&.dig(:current_user) || controller&.current_user
    end

    private

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
