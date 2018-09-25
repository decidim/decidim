# frozen_string_literal: true

module Decidim
  module Accountability
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
