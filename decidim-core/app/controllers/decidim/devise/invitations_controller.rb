# frozen_string_literal: true
module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Invitiable.
    class InvitationsController < ::Devise::InvitationsController
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
    end
  end
end
