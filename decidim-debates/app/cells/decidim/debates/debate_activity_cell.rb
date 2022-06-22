# frozen_string_literal: true

module Decidim
  module Debates
    # A cell to display when actions happen on a debate.
    class DebateActivityCell < ActivityCell
      def title
        I18n.t(
          action_key,
          scope: "decidim.debates.last_activity"
        )
      end

      def action_key
        action == "update" ? "debate_updated" : "new_debate"
      end

      def resource_link_text
        Decidim::Debates::DebatePresenter.new(resource).title
      end
    end
  end
end
