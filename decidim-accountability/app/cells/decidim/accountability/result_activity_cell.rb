# frozen_string_literal: true

module Decidim
  module Accountability
    # A cell to display when a Result has been created.
    class ResultActivityCell < ActivityCell
      def title
        I18n.t(
          "new_result",
          scope: "decidim.accountability.last_activity"
        )
      end
    end
  end
end
