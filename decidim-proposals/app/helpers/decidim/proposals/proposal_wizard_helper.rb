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
      def step_classes(step, current_step)
        step_i = step.to_s.split("_").last.to_i
        current_step_i = current_step.to_s.split("_").last.to_i
        if step_i <= current_step_i
          %(phase-item--past #{step} #{current_step})
        else
          %()
        end
      end

      def proposal_wizard_stepper_step(step, current_step)
        html = %(<li class="#{step_classes(step, current_step)}">)
        html += %(<span></span>)
        html += %(<div class="caption">#{t(".#{step}")}</div>)
        html += %(</li>)
        html
      end

      def proposal_wizard_stepper(current_step)
        content_tag :ol do
          %(
            #{proposal_wizard_stepper_step(:step_1, current_step)}
            #{proposal_wizard_stepper_step(:step_2, current_step)}
            #{proposal_wizard_stepper_step(:step_3, current_step)}
          ).html_safe
        end
      end
    end
  end
end
