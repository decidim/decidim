# frozen_string_literal: true

module Decidim
  module Accountability
    # A cell to display when a Result has been created.
    class ResultActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.accountability.last_activity.new_result_at_html",
          link: participatory_space_link
        )
      end
    end
  end
end
