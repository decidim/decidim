# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the steps header
    class StepsHeaderCell < Decidim::ViewModel
      def show
        return if questionnaires_ids == [questionnaire.id]

        render :show
      end

      def total_questionnaires
        questionnaires_ids.count
      end

      def current_index
        questionnaires_ids.index(questionnaire.id) + 1
      end

      def questionnaire
        model
      end

      def questionnaires_ids
        options[:questionnaires].map(&:id)
      end
    end
  end
end
