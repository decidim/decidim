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
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
          params = {
            category: form.category,
            title: parsed_title,
            description: parsed_description,
            information_updates: form.information_updates,
            instructions: form.instructions,
            end_time: (form.end_time if form.finite),
            start_time: (form.start_time if form.finite),
            scope: form.scope,
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
