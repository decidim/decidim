# frozen_string_literal: true

module Decidim
  # Shared behaviour for signed_in users that require the latest TOS accepted
  module HasStoredPath
    extend ActiveSupport::Concern

    included do
      # Saves the location before loading each page so we can return to the
      # right page.
      before_action :store_current_location
    end

    # Stores the url where the user will be redirected after login.
    #
    # Uses the `redirect_url` param or the current url if there's no param.
    # In Devise controllers we only store the URL if it's from the params, we don't
    # want to overwrite the stored URL for a Devise one.
    def store_current_location
      return if skip_store_location?

      value = redirect_url || request.url
      store_location_for(:user, value)
    end

    def skip_store_location?
      # Skip if Devise already handles the redirection
      return true if devise_controller? && redirect_url.blank?
      # Skip for all non-HTML requests"
      return true unless request.format.html?
      # Skip if a signed in user requests the TOS page without having agreed to
      # the TOS. Most of the times this is because of a redirect to the TOS
      # page (in which case the desired location is somewhere else after the
      # TOS is agreed).
      return true if current_user && !current_user.tos_accepted? && request.path == URI(tos_path).path

      false
    end
  end
end
