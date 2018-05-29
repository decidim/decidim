# frozen-string_literal: true

module Decidim
  module Initiatives
    class EndorseInitiativeEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.initiatives.events.endorse_initiative_event"
      end
    end
  end
end
