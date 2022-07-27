# frozen_string_literal: true

module Decidim
  module Debates
    # A cell to display when actions happen on a debate.
    class DebateActivityCell < ActivityCell
      def title
        case action
        when "update"
          I18n.t(
            "decidim.debates.last_activity.debate_updated_at_html",
            link: participatory_space_link
          )
        else
          I18n.t(
            "decidim.debates.last_activity.new_debate_at_html",
            link: participatory_space_link
          )
        end
      end

      def resource_link_text
        presenter.title
      end

      def description
        strip_tags(presenter.description(links: true))
      end

      def presenter
        @presenter ||= Decidim::Debates::DebatePresenter.new(resource)
      end
    end
  end
end
