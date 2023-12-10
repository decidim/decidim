# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # A command with all the business logic when an admin closes a debate.
      class CloseDebate < Decidim::Debates::CloseDebate
        private

        def attributes
          {
            conclusions: form.conclusions,
            closed_at: form.closed_at
          }
        end
        #
        # def close_debate
        #   @debate = Decidim.traceability.perform_action!(
        #     :close,
        #     form.debate,
        #     form.current_user
        #   ) do
        #     form.debate.update!(
        #       conclusions: form.conclusions,
        #       closed_at: form.closed_at
        #     )
        #   end
        #
        #   Decidim::EventsManager.publish(
        #     event: "decidim.events.debates.debate_closed",
        #     event_class: Decidim::Debates::CloseDebateEvent,
        #     resource: debate,
        #     followers: debate.followers
        #   )
        # end
      end
    end
  end
end
