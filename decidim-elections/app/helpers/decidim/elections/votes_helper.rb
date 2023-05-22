# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for the voting booth views.
    #
    module VotesHelper
      def ordered_answers(question)
        if question.random_answers_order
          question.answers.shuffle
        else
          question.answers.sort_by { |answer| [answer.weight, answer.id] }
        end
      end

      def more_information?(answer)
        translated_attribute(answer.description).present? ||
          answer.proposals.any? ||
          answer.photos.any?
      end

      def election_wizard_steps
        ["register", "election", "confirm", "ballot_decision"]
      end

      def wizard_steps(current_step)
        scope = "decidim.elections.votes.header"
        inactive_data = { data: { past: "" } }
        content_tag(:ol, id: "wizard-steps", class: "wizard-steps") do
          election_wizard_steps.map do |wizard_step|
            active = current_step == wizard_step
            inactive_data = {} if active
            attributes = active ? { "aria-current": "step", "aria-label": "#{t("current_step", scope:)}: #{t(wizard_step, scope:)}", data: { active: "" } } : inactive_data
            content_tag(:li, t(wizard_step, scope:), attributes)
          end.join.html_safe
        end
      end
    end
  end
end
