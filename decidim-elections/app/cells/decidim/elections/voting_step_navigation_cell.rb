# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the navigation of a questionnaire step.
    class VotingStepNavigationCell < Decidim::ViewModel
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

      def button_continue_text
        "#{t("decidim.elections.votes.voting_step.continue")}  #{icon("chevron-right", class: "icon", role: "img")}"
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
    end
  end
end
