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
        # When private user is destroyed, a hook to destroy the follows of user on private non transparent assembly
        # or private participatory process and the follows of their children
        space = resource.privatable_to_type.constantize.find(resource.privatable_to_id)

        return unless space.private_space?

        return if space.respond_to?(:is_transparent) && space.is_transparent?

        decidim_user_id = resource.decidim_user_id
        privatable_to_type = resource.privatable_to_type

        DestroyPrivateUsersFollowsJob.perform_later(decidim_user_id, privatable_to_type, space)
      end
    end
  end
end
