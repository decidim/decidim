# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # This controller allows the user to accept the cookie policy.
  class CookiePolicyController < ApplicationController
    skip_authorization_check

    def accept
      response.set_cookie "decidim-cc", value: "true",
                                        path: "/",
                                        expires: 1.year.from_now.utc
    end
  end
end
