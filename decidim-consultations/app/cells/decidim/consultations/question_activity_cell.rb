# frozen_string_literal: true

module Decidim
  module Consultations
    class QuestionActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.consultations.last_activity.new_question_at_html",
          link: participatory_space_link
        )
      end
    end
  end
end
