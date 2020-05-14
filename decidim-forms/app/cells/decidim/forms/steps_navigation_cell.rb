# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the steps navigation (the buttons to move between steps
    # and the submit button).
    class StepsNavigationCell < Decidim::ViewModel
      def first_step?
        current_index == 1
      end

      def last_step?
        current_index == total_questionnaires
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

      def form
        options[:form]
      end

      def disabled?
        options[:disabled]
      end
    end
  end
end
