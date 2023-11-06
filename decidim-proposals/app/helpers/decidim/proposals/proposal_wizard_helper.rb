# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal wizard partials
    module ProposalWizardHelper
      def wizard_steps(current_step)
        scope = "decidim.proposals.proposals.wizard_steps"
        inactive_data = { data: { past: "" } }
        content_tag(:ol, id: "wizard-steps", class: "wizard-steps") do
          proposal_wizard_steps.map do |wizard_step|
            active = current_step == wizard_step
            inactive_data = {} if active
            attributes = active ? { "aria-current": "step", "aria-label": "#{t("current_step", scope:)}: #{t(wizard_step, scope:)}", data: { active: "" } } : inactive_data
            content_tag(:li, t(wizard_step, scope:), attributes)
          end.join.html_safe
        end
      end

      # Returns the page title of the given step, translated
      #
      # action_name - A string of the rendered action
      def proposal_wizard_step_title(action_name)
        step_title = case action_name
                     when "create"
                       "new"
                     when "update_draft"
                       "edit_draft"
                     else
                       action_name
                     end

        t("decidim.proposals.proposals.#{step_title}.title")
      end

      # Returns a boolean if the step has a help text defined
      #
      # step - A symbol of the target step
      def proposal_wizard_step_help_text?(step)
        translated_attribute(component_settings.try("proposal_wizard_#{step}_help_text")).present?
      end

      def proposal_wizard_steps
        [ProposalsController::STEP1, ProposalsController::STEP2, ProposalsController::STEP3, ProposalsController::STEP4]
      end

      private

      def total_steps
        4
      end

      # Renders the back link except for step_2: compare
      def proposal_wizard_aside_link_to_back(step)
        case step
        when ProposalsController::STEP1
          proposals_path
        when ProposalsController::STEP3
          compare_proposal_path
        when ProposalsController::STEP4
          edit_draft_proposal_path
        end
      end

      def wizard_aside_back_text(from = nil)
        key = "back"
        key = "back_from_#{from}" if from

        t(key, scope: "decidim.proposals.proposals.wizard_aside").html_safe
      end
    end
  end
end
