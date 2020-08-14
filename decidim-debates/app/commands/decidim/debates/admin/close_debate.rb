# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # A command with all the business logic when an admin closes a debate.
      class CloseDebate < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the debate.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          close_debate
          broadcast(:ok, debate)
        end

        private

        attr_reader :form

        def close_debate
          @debate = Decidim.traceability.perform_action!(
            :close,
            form.debate,
            form.current_user
          ) do
            form.debate.update!(
              conclusions: form.conclusions,
              closed_at: form.closed_at
            )
          end

          Decidim::EventsManager.publish(
            event: "decidim.events.debates.debate_closed",
            event_class: Decidim::Debates::CloseDebateEvent,
            resource: debate,
            followers: debate.followers
          )
        end
      end
    end
  end
end
