# frozen_string_literal: true

module Decidim
  module Initiatives
    class LikeInitiativeEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.initiatives.events.like_initiative_event"
      end
    end
  end
end
