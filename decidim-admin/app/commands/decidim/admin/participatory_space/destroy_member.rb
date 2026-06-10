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
          return unless resource.participatory_space.respond_to?(:restricted?)
          return unless resource.participatory_space.restricted?
          return if resource.participatory_space.respond_to?(:transparent?) && resource.participatory_space.transparent?

          # When member is destroyed, a hook to destroy the follows of user on restricted or transparent spaces
          # and the follows of their children
          DestroyMembersFollowsJob.perform_later(resource.decidim_user_id, resource.participatory_space)
        end
      end
    end
  end
end
