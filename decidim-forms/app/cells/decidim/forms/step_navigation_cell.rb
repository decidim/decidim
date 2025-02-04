# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the navigation of a questionnaire step.
    class StepNavigationCell < Decidim::ViewModel
      def current_step_index
        model
      end

      def first_step?
        current_step_index.zero?
      end

      def last_step?
        current_step_index + 1 == total_steps
      end

      def total_steps
        options[:total_steps]
      end

      def form
        options[:form]
      end

      def button_disabled?
        options[:button_disabled]
      end

      def previous_step_dom_id
        "step-#{current_step_index - 1}"
      end

      def next_step_dom_id
        "step-#{current_step_index + 1}"
      end

      def current_step_dom_id
        "step-#{current_step_index}"
      end

      def allow_editing_answers?
        options[:allow_editing_answers]
      end

      def confirm_data
        {
          data: {
            confirm:,
            disable: true,
            data: "survey-buttons"
          }
        }
      end

      def confirm
        return t("decidim.forms.step_navigation.show.are_you_sure_no_edit") unless allow_editing_answers?
        return t("decidim.forms.step_navigation.show.are_you_sure_edit_guest") unless current_user

        t("decidim.forms.step_navigation.show.are_you_sure_edit")
      end
    end
  end
end
