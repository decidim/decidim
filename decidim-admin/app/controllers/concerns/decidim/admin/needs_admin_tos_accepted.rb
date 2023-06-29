# frozen_string_literal: true

module Decidim
  module Admin
    # Shared behaviour for signed_in admins that require the latest TOS accepted
    module NeedsAdminTosAccepted
      extend ActiveSupport::Concern

      included do
        before_action :tos_accepted_by_admin
      end

      private

      def tos_accepted_by_admin
        return unless request.format.html?
        return unless current_user
        return if current_user.admin_terms_accepted?
        return if permitted_paths?

        store_location_for(
          current_user,
          request.path
        )
        redirect_to admin_tos_path
      end

      def permitted_paths?
        # ensure that path with or without query string pass
        permitted_paths.find { |el| el.split("?").first == request.path }
      end

      def permitted_paths
        [admin_tos_path, decidim_admin.admin_terms_accept_path]
      end

      def admin_tos_path
        decidim_admin.admin_terms_show_path
      end
    end
  end
end
