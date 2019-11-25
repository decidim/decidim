# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module NeedsAdminTermsAccepted
        extend ActiveSupport::Concern

        included do
          before_action :ensure_admin_terms_accepted
        end

        private

        def ensure_admin_terms_accepted
          return true unless request.format.html?
          return true unless current_user
          return if current_user.admin_terms_accepted?

          # return if admin_permitted_path?

          # redirect_to_admin_terms
        end

        def admin_permitted_path?
          # permit: decidim_admin.initiatives_paths
          admin_permitted_paths = [
            decidim_admin.admin_terms_of_use_path,
            decidim_admin.accept_admin_terms_of_use_path,
            decidim_admin.root_path
          ]
          # ensure that path with or without query string pass
          admin_permitted_paths.find { |el| el.split("?").first == request.path }
        end

        def redirect_to_admin_terms
          # Store the location where the user needs to be redirected to after the
          # Admin Terms agreement.
          store_location_for(
            current_user,
            stored_location_for(current_user) || request.path
          )

          flash[:notice] = flash[:notice] if flash[:notice]
          flash[:warning] = t("required_review.alert", scope: "decidim.admin.admin_terms_of_use")
          redirect_to decidim_admin.admin_terms_of_use_path
        end
      end
    end
  end
end
