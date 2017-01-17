# frozen_string_literal: true
module Decidim
  module Devise
    # This controller customizes the behaviour of Devise's
    # RegistrationsController so we can specify a custom layout.
    class RegistrationsController < ::Devise::RegistrationsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/application"
      before_action :configure_permitted_parameters

      protected

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :tos_agreement])
      end

      # Called before resource.save
      def build_resource(hash = nil)
        super(hash)
        resource.organization = current_organization
      end
    end
  end

end
