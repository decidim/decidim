# frozen_string_literal: true

module Decidim
  # This module includes helpers to verify the acceptance of the cookie policy
  module CookiesHelper
    # Public: Returns true if the cookie policy has been accepted
    def cookies_accepted?
      cookies[Decidim.config.consent_cookie_name].present?
    end
  end
end
