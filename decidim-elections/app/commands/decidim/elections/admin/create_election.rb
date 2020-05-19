# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user creates an Election
      # from the admin panel.
      class CreateElection < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the election if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_election!
            send_notification
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :form, :election

        def create_election!
          attributes = {
            title: form.title,
            subtitle: form.subtitle,
            description: form.description,
            start_time: form.start_time,
            end_time: form.end_time,
            component: form.current_component
          }

          @election = Decidim.traceability.create!(
            Election,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.elections.election_created",
            event_class: Decidim::Elections::CreateElectionEvent,
            resource: election,
            followers: election.participatory_space.followers
          )
        end
      end
    end
  end
end
