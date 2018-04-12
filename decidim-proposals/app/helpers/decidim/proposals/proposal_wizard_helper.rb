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
        t(:"decidim.proposals.proposals.wizard_steps.#{step}")
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
        content_tag(:li, proposal_wizard_step_name(step), class: proposal_wizard_step_classes(step, current_step).to_s)
      end

      # Returns the list with all the steps, in html
      #
      # current_step - A symbol of the current step
      def proposal_wizard_stepper(current_step)
        content_tag :ol, class: "wizard__steps" do
          %(
            #{proposal_wizard_stepper_step(:step_1, current_step)}
            #{proposal_wizard_stepper_step(:step_2, current_step)}
            #{proposal_wizard_stepper_step(:step_3, current_step)}
          ).html_safe
        end
      end

      # Returns a string with the current step number and the total steps number
      #
      # step - A symbol of the target step
      def proposal_wizard_current_step_of(step)
        current_step_num = proposal_wizard_step_number(step)
        content_tag :span, class: "text-small" do
          concat t(:"decidim.proposals.proposals.wizard_steps.step_of", current_step_num: current_step_num, total_steps: 3)
          concat " ("
          concat content_tag :a, t(:"decidim.proposals.proposals.wizard_steps.see_steps"), "data-toggle": "steps"
          concat ")"
        end
      end

      # Returns a boolean if the step has a help text defined
      #
      # step - A symbol of the target step
      def proposal_wizard_step_help_text?(step)
        translated_attribute(feature_settings.try("proposal_wizard_#{step}_help_text")).present?
      end

      # Renders a user_group select field in a form.
      # form - FormBuilder object
      # name - attribute user_group_id
      #
      # Returns nothing.
      def user_group_select_field(form, name)
        form.select(name, current_user.user_groups.verified.map { |g| [g.name, g.id] }, prompt: current_user.name)
      end
    end
  end
end
