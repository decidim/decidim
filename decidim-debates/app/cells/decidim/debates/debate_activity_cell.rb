# frozen_string_literal: true

module Decidim
  module Debates
    # A cell to display when Debate has been created.
    class DebateActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.debates.last_activity.new_debate_at_html",
          link: participatory_space_link
        )
      end
    end
  end
end
