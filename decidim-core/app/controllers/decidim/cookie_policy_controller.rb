# frozen_string_literal: true

module Decidim
  # This controller allows the user to accept the cookie policy.
  class CookiePolicyController < Decidim::ApplicationController
    skip_authorization_check

    def accept
      response.set_cookie "decidim-cc", value: "true",
                                        path: "/",
                                        expires: 1.year.from_now.utc

      respond_to do |format|
        format.js
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end
end
