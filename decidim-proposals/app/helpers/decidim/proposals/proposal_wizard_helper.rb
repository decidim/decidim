# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal wizard partials
    module ProposalWizardHelper
      # Returns the css classes used for proposal votes count in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a hash with the css classes for the count number and label
      def proposal_wizard_step_classes(step, current_step)
        step_i = step.to_s.split("_").last.to_i
        if step_i == proposal_wizard_step_number(current_step)
          %(step--active #{step} #{current_step})
        else
          %()
        end
      end

      def proposal_wizard_step_number(step)
        step.to_s.split("_").last.to_i
      end

      def proposal_wizard_step_name(step)
        t(:"decidim.proposals.proposals.wizard_steps.#{step}")
      end

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

      def proposal_wizard_stepper_step(step, current_step)
        content_tag(:li, proposal_wizard_step_name(step), class: proposal_wizard_step_classes(step, current_step).to_s)
      end

      def proposal_wizard_stepper(current_step)
        content_tag :ol, class: "wizard__steps" do
          %(
            #{proposal_wizard_stepper_step(:step_1, current_step)}
            #{proposal_wizard_stepper_step(:step_2, current_step)}
            #{proposal_wizard_stepper_step(:step_3, current_step)}
          ).html_safe
        end
      end

      def proposal_wizard_current_step_of(current_step_num)
        content_tag :span, class: "text-small" do
          concat t(:"decidim.proposals.proposals.wizard_steps.step_of", current_step_num: current_step_num, total_steps: 3)
          concat " ("
          concat content_tag :a, t(:"decidim.proposals.proposals.wizard_steps.see_steps"), "data-toggle": "steps"
          concat ")"
        end
      end
    end
  end
end
