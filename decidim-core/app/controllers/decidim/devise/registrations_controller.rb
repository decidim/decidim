# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise's
    # RegistrationsController so we can specify a custom layout.
    class RegistrationsController < ::Devise::RegistrationsController
      include FormFactory
      include Decidim::DeviseControllers

      helper_method :terms_and_conditions_page

      before_action :configure_permitted_parameters
      helper_method :terms_and_conditions_page

      invisible_captcha

      def new
        @form = form(RegistrationForm).from_params(
          user: {
            sign_up_as: "user"
          }
        )
      end

      def create
        @form = form(RegistrationForm).from_params(params[:user])

        CreateRegistration.call(@form) do
          on(:ok) do |user|
            if user.active_for_authentication?
              set_flash_message! :notice, :signed_up
              sign_up(:user, user)
              respond_with user, location: after_sign_up_path_for(user)
            else
              set_flash_message! :notice, :"signed_up_but_#{user.inactive_message}"
              expire_data_after_sign_in!
              respond_with user, location: after_inactive_sign_up_path_for(user)
            end
          end

          on(:invalid) do
            render :new
          end
        end
      end

      private

      def terms_and_conditions_page
        @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions")
      end

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
