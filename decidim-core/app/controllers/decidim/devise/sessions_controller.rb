# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      layout "application"

      def after_sign_in_path_for(user)
        if user.role?(:admin)
          decidim_admin.root_path
        elsif user.is_a?(User) && user.sign_in_count == 1 && Decidim.authorization_handlers.any?
          authorizations_path
        else
          super
        end
      end
    end
  end
end
