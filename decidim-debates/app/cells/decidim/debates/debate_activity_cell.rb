# frozen_string_literal: true

module Decidim
  module Debates
    # A cell to display when actions happen on a debate.
    class DebateActivityCell < ActivityCell
      def title
        action == "update" ? I18n.t("decidim.debates.last_activity.debate_updated") : I18n.t("decidim.debates.last_activity.new_debate")
      end

      def resource_link_text
        Decidim::Debates::DebatePresenter.new(resource).title
      end
    end
  end
end
