# frozen_string_literal: true

module Decidim
  module Budgets
    # A cell to display when actions happen on a proposal.
    class OrderActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.budgets.last_activity.new_vote_at_html",
          link: participatory_space_link
        )
      end

      def resource_link_path
        resource_locator(budget).path
      end

      def resource_link_text
        decidim_html_escape(translated_attribute(budget.title))
      end

      private

      def budget
        @budget ||= resource.budget
      end
    end
  end
end
