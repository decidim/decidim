# frozen_string_literal: true

module Decidim
  module System
    module Devise
      # Custom Sessions controller for Devise in order to use a custom layout
      # and views.
      class SessionsController < ::Devise::SessionsController
        include Decidim::LocaleSwitcher

        helper Decidim::DecidimFormHelper

        rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_to_referer_or_path

        layout "decidim/system/login"

        private

        def redirect_to_referer_or_path
          set_flash_message(:alert, "csrf_token", scope: "devise.failure")
          redirect_back(fallback_location: root_path)
        end

        def current_organization; end
      end
    end
  end
end
