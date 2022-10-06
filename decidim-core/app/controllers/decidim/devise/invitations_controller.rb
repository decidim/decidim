# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Invitiable.
    class InvitationsController < ::Devise::InvitationsController
      include Decidim::DeviseControllers
      include NeedsTosAccepted

      helper Decidim::PasswordsHelper

      before_action :configure_permitted_parameters

      # We don't users to create invitations, so we just redirect them to the
      # homepage.
      def authenticate_inviter!
        redirect_to root_path
      end

      # Overwrite the method that returns the path after a user accepts an
      # invitation. Using the param `invite_redirect` we can redirect the user
      # to a custom path after it has accepted the invitation.
      def after_accept_path_for(resource)
        params[:invite_redirect] || after_sign_in_path_for(resource)
      end

      # When a managed user accepts the invitation is promoted to non-managed user.
      def accept_resource
        resource = resource_class.accept_invitation!(update_resource_params)

        if resource.valid? && resource.invitation_accepted?
          resource.update!(newsletter_notifications_at: Time.current) if update_resource_params[:newsletter_notifications]
          resource.update!(managed: false) if resource.managed?
          resource.update!(accepted_tos_version: resource.organization.tos_version)
          Decidim::Gamification.increment_score(resource.invited_by, :invitations) if resource.invited_by
        end

        resource
      end

      protected

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:accept_invitation, keys: [:nickname, :tos_agreement, :newsletter_notifications])
      end
    end
  end
end
