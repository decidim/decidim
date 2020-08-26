# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user updates an Election
      # from the admin panel.
      class UpdateElection < Rectify::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        # Updates the election if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_election!

          broadcast(:ok, election)
        end

        private

        attr_reader :form, :election

        def update_election!
          attributes = {
            title: form.title,
            subtitle: form.subtitle,
            description: form.description,
            start_time: form.start_time,
            end_time: form.end_time
          }

          Decidim.traceability.update!(
            election,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
