# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal wizard partials
    module ProposalWizardHelper
      # Returns the css classes used for the proposal wizard for the desired step
      #
      # step - A symbol of the target step
      # current_step - A symbol of the current step
      #
      # Returns a string with the css classes for the desired step
      def proposal_wizard_step_classes(step, current_step)
        step_i = step.to_s.split("_").last.to_i
        if step_i == proposal_wizard_step_number(current_step)
          %(step--active #{step} #{current_step})
        elsif step_i < proposal_wizard_step_number(current_step)
          %(step--past #{step})
        else
          %()
        end
      end

      # Returns the number of the step
      #
      # step - A symbol of the target step
      def proposal_wizard_step_number(step)
        step.to_s.split("_").last.to_i
      end

      # Returns the name of the step, translated
      #
      # step - A symbol of the target step
      def proposal_wizard_step_name(step)
        t("decidim.proposals.proposals.wizard_steps.#{step}")
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

      # Returns the list item of the given step, in html
      #
      # step - A symbol of the target step
      # current_step - A symbol of the current step
      def proposal_wizard_stepper_step(step, current_step)
        attributes = { class: proposal_wizard_step_classes(step, current_step).to_s }
        step_title = proposal_wizard_step_name(step)
        if step.to_s.split("_").last.to_i == proposal_wizard_step_number(current_step)
          current_step_title = proposal_wizard_step_name("current_step")
          step_title = content_tag(:span, "#{current_step_title}: ", class: "show-for-sr") + step_title
          attributes["aria-current"] = "step"
        end

        content_tag(:li, step_title, attributes)
      end

      # Returns the list with all the steps, in html
      #
      # current_step - A symbol of the current step
      def proposal_wizard_stepper(current_step)
        content_tag :ol, class: "wizard__steps" do
          %(
            #{proposal_wizard_stepper_step(ProposalsController::STEP1, current_step)}
            #{proposal_wizard_stepper_step(ProposalsController::STEP2, current_step)}
            #{proposal_wizard_stepper_step(ProposalsController::STEP3, current_step)}
            #{proposal_wizard_stepper_step(ProposalsController::STEP4, current_step)}
          ).html_safe
        end
      end

      # Returns a string with the current step number and the total steps number
      #
      def proposal_wizard_current_step_of(step)
        current_step_num = proposal_wizard_step_number(step)
        see_steps = content_tag(:span, class: "hide-for-large") do
          concat " ("
          concat content_tag :a, t(:"decidim.proposals.proposals.wizard_steps.see_steps"), "data-toggle": "steps"
          concat ")"
        end
        content_tag :span, class: "text-small" do
          concat t(:"decidim.proposals.proposals.wizard_steps.step_of", current_step_num:, total_steps:)
          concat see_steps
        end
      end

      def proposal_wizard_steps_title
        t("title", scope: "decidim.proposals.proposals.wizard_steps")
      end

      # Returns a boolean if the step has a help text defined
      #
      # step - A symbol of the target step
      def proposal_wizard_step_help_text?(step)
        translated_attribute(component_settings.try("proposal_wizard_#{step}_help_text")).present?
      end

      private

      def total_steps
        4
      end

      def wizard_aside_info_text
        t("info", scope: "decidim.proposals.proposals.wizard_aside").html_safe
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
