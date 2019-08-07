# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user creates a Debate from the admin
      # panel.
      class CreateDebate < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the debate if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_debate
            send_notification_to_space_followers
          end
          broadcast(:ok)
        end

        private

        attr_reader :debate, :form

        def create_debate
          params = {
            category: form.category,
            title: form.title,
            description: form.description,
            information_updates: form.information_updates,
            instructions: form.instructions,
            end_time: form.end_time,
            start_time: form.start_time,
            component: form.current_component,
            author: form.current_organization
          }

          @debate = Decidim.traceability.create!(
            Debate,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def send_notification_to_space_followers
          Decidim::EventsManager.publish(
            event: "decidim.events.debates.debate_created",
            event_class: Decidim::Debates::CreateDebateEvent,
            resource: debate,
            followers: form.current_component.participatory_space.followers,
            extra: {
              type: "participatory_space"
            }
          )
        end
      end
    end
  end
end
