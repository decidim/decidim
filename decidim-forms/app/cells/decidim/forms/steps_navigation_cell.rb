# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the steps navigation (the buttons to move between steps
    # and the submit button).
    class StepsNavigationCell < Decidim::ViewModel
      include Decidim::LayoutHelper

      delegate :first_step?,
               :last_step?,
               :previous_step_id,
               :next_step_id,
               to: :questionnaire

      def total_questionnaires
        questionnaire.sibling_questionnaires_ids.count
      end

      def current_index
        questionnaire.step_index + 1
      end

      def questionnaire
        model
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

      def answer_form_url
        options[:answer_form_url]
      end

      def answer_and_next_step_url
        options[:answer_and_next_step_url]
      end

      def answer_and_previous_step_url
        options[:answer_and_previous_step_url]
      end
    end
  end
end
