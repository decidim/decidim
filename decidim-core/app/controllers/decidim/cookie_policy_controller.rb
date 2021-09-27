# frozen_string_literal: true

module Decidim
  # This controller allows the user to accept the cookie policy.
  class CookiePolicyController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def accept
      response.set_cookie(
        Decidim.config.consent_cookie_name,
        value: "true",
        path: "/",
        httponly: true,
        secure: request.session_options[:secure],
        expires: 1.year.from_now.utc
      )

      respond_to do |format|
        format.js
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end
end
