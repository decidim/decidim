# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a participatory space private user.
    class DestroyParticipatorySpacePrivateUser < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          resource: {
            title: resource.user.name
          }
        }
      end

      def run_after_hooks
        # When private user is destroyed, a hook to destroy the follows of user on private non-transparent assembly
        # or private participatory process and the follows of their children
        DestroyPrivateUsersFollowsJob.perform_later(resource.decidim_user_id, resource.privatable_to)
      end
    end
  end
end
