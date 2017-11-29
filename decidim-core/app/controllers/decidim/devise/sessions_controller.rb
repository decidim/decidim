# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      def after_sign_in_path_for(user)
        if first_login_and_not_authorized?(user) && !user.admin?
          decidim_verifications.first_login_authorizations_path
        else
          super
        end
      end

      def first_login_and_not_authorized?(user)
        user.is_a?(User) && user.sign_in_count == 1 && current_organization.available_authorizations.any?
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end
    end
  end
end
