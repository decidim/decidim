# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Invitiable.
    class InvitationsController < ::Devise::InvitationsController
      include Decidim::DeviseControllers

      # We don't users to create invitations, so we just redirect them to the
      # homepage.
      def authenticate_inviter!
        redirect_to root_path
      end

      # Overwrite the method that returns the path after a user accepts an
      # invitation. Using the param `invite_redirect` we can redirect the user
      # to a custom path after it has accepted the invitation.
      def after_accept_path_for(resource)
        params[:invite_redirect] || super
      end

      # When a managed user accepts the invitation is promoted to non-managed user.
      def accept_resource
        resource = resource_class.accept_invitation!(update_resource_params)
        resource.update_attributes!(managed: false) if resource.managed?
        resource
      end
    end
  end
end
