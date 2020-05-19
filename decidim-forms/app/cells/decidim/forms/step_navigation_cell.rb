# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders the navigation of a questionnaire step.
    class StepNavigationCell < Decidim::ViewModel
      include Decidim::LayoutHelper

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
    end
  end
end
