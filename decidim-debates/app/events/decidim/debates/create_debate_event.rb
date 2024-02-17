# frozen_string_literal: true

module Decidim
  module Debates
    # Notifies users about a new debate. Accepts a Hash in the `extra`
    # field with the key `:type`, which can hold two different values:
    #
    # "user" - The event is being sent to the followers of the debate
    #          author
    # "participatory_space" - The event is being sent to the followers
    #                         of the event's participatory space.
    class CreateDebateEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def resource_text
        translated_attribute(resource.description)
      end

      private

      def i18n_scope
        @i18n_scope ||= if extra[:type].to_s == "user"
                          "decidim.events.debates.create_debate_event.user_followers"
                        else
                          "decidim.events.debates.create_debate_event.space_followers"
                        end
      end
    end
  end
end
