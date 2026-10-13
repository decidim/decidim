# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # registration type in the system.
      class DestroyRegistrationType < Decidim::Commands::DestroyResource
        # The check and the deletion must share one transaction with the row locked, otherwise a
        # concurrent JoinConference could insert a registration between the check and the deletion,
        # and the dependent: :destroy cascade would silently unregister that participant.
        # JoinConference acquires the same lock, so the two flows serialize on this row.
        def call
          resource.with_lock do
            return broadcast(:invalid) if invalid?

            run_before_hooks
            destroy_resource
            run_after_hooks

            broadcast(:ok, resource)
          end
        rescue Decidim::Commands::HookError, StandardError
          broadcast(:invalid)
        end

        protected

        # The index view only shows the delete action for types without registrations, but the
        # server-side entry point cannot rely on that. The check runs against the actual rows
        # instead of the cached counter, so a direct request cannot delete a type that participants
        # are still registered to.
        def invalid?
          resource.conference_registrations.exists?
        end

        def extra_params
          {
            resource: {
              title: resource.title
            },
            participatory_space: {
              title: resource.conference.title
            }
          }
        end
      end
    end
  end
end
