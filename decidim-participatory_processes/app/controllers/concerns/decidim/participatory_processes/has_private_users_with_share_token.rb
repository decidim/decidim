# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatoryProcesses
    module HasPrivateUsersWithShareToken
      extend ActiveSupport::Concern

      def use_share_token
        enforce_permission_to :use_share_token, :process, process: current_participatory_space, share_token: share_token

        Decidim::ParticipatorySpacePrivateUser.find_or_create_by!(
          user: current_user,
          privatable_to: current_participatory_space
        )

        unless current_user.invitation_accepted?
          current_user.accept_invitation
          current_user.save
        end
        redirect_to action: :show
      end

      private

      def share_token
        params[:share_token]
      end
    end
  end
end
