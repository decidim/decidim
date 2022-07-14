# frozen_string_literal: true

module Decidim
  module Consultations
    # A cell to display when a Question in a consultation has been published.
    class QuestionActivityCell < ActivityCell
      def title
        I18n.t("decidim.consultations.last_activity.new_question")
      end
    end
  end
end
