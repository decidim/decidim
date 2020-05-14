# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the steps navigation (the buttons to move between steps
    # and the submit button).
    class StepsNavigationCell < Decidim::ViewModel
      include Decidim::LayoutHelper

      def first_step?
        questionnaire.id == questionnaires_ids.first
      end

      def last_step?
        questionnaire.id == questionnaires_ids.last
      end

      def total_questionnaires
        questionnaires_ids.count
      end

      def current_index
        questionnaires_ids.index(questionnaire.id)
      end

      def questionnaire
        model
      end

      def questionnaires_ids
        options[:questionnaires].map(&:id)
      end

      def previous_questionnaire_id
        questionnaires_ids[current_index - 1]
      end

      def next_questionnaire_id
        questionnaires_ids[current_index + 1]
      end

      def form
        options[:form]
      end

      def disabled?
        options[:disabled]
      end

      def questionnaire_path(args)
        options[:questionnaire_path].call(args)
      end
    end
  end
end
