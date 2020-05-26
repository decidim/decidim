# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders a question (readonly) of a questionnaire
    class QuestionReadonlyCell < Decidim::ViewModel
      def show
        return if model.separator?

        render :show
      end
    end
  end
end
