# frozen_string_literal: true

module Decidim
  module Consultations
    # A cell to display when a Question in a consultation has been published.
    class QuestionActivityCell < ActivityCell
      def title
        I18n.t(
          "new_question",
          scope: "decidim.consultations.last_activity"
        )
      end
    end
  end
end
