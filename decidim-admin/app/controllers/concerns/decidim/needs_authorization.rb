# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need authorization to work.
  module NeedsAuthorization
    extend ActiveSupport::Concern

    included do

      private

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_not_authorized
        flash[:alert] = t("actions.unauthorized", scope: "decidim.admin")
        redirect_to(request.referrer || decidim_admin.root_path)
      end
    end
  end
end
