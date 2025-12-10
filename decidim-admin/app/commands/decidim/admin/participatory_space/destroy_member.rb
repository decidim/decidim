# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # A command with all the business logic to destroy a member.
      class DestroyMember < Decidim::Commands::DestroyResource
        private

        def extra_params
          {
            resource: {
              title: resource.user.name
            }
          }
        end

        def run_after_hooks
          return unless resource.privatable_to.respond_to?(:private_space?)
          return unless resource.privatable_to.private_space?
          return if resource.privatable_to.respond_to?(:is_transparent) && resource.privatable_to.is_transparent?

          # When member is destroyed, a hook to destroy the follows of user on private non-transparent assembly
          # or private participatory process and the follows of their children
          DestroyMembersFollowsJob.perform_later(resource.decidim_user_id, resource.privatable_to)
        end
      end
    end
  end
end
