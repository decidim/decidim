# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise PasswordsController to avoid namespace problems.
    class PasswordsController < ::Devise::PasswordsController
      include Decidim::DeviseControllers
      include Decidim::PasswordsHelper

      prepend_before_action :require_no_authentication, except: [:change_password, :apply_password]
      skip_before_action :store_current_location

      before_action :check_sign_in_enabled

      helper_method :password_help_text

      def change_password
        enforce_permission_to :change_admin_password, :user, current_user: current_user

        self.resource = current_user
        @send_path = apply_password_path

        flash[:secondary] = t("decidim.admin.password_change.notification", days: Decidim.config.admin_password_days_expiration) if flash[:secondary].blank?
        render :edit
      end

      def apply_password
        enforce_permission_to :change_admin_password, :user, current_user: current_user

        self.resource = current_user
        @send_path = apply_password_path

        @form = Decidim::PasswordForm.from_params(params["user"])
        Decidim::UpdatePassword.call(current_user, @form) do
          on(:ok) do
            flash[:notice] = t("passwords.update.success", scope: "decidim")
            bypass_sign_in(current_user)
            redirect_to after_sign_in_path_for current_user
          end

          on(:invalid) do
            flash.now[:alert] = t("passwords.update.error", scope: "decidim")
            resource.errors.errors.concat(@form.errors.errors)
            render action: "edit"
          end
        end
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end

      # Since we're using a single Devise installation for multiple
      # organizations, and user emails can be repeated across organizations,
      # we need to identify the user by both the email and the organization.
      # Setting the organization ID here will be used by Devise internally to
      # find the correct user.
      #
      # Note that in order for this to work we need to define the `reset_password_keys`
      # Devise attribute in the `Decidim::User` model to include the
      # `decidim_organization_id` attribute.
      def resource_params
        super.merge(decidim_organization_id: current_organization.id)
      end

      def user_has_no_permission_path
        return decidim.new_user_session_path unless user_signed_in?

        decidim.root_path
      end
    end
  end
end
