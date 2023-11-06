# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders a question (readonly) of a questionnaire
    class QuestionReadonlyCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def show
        return if model.separator?
        return render :title_and_description if model.title_and_description?

        render :show
      end

      def position
        options[:indexed_items].index(model.id) + 1
      end
    end
  end
end
