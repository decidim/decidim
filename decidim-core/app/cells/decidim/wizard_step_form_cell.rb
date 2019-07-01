# frozen_string_literal: true

module Decidim
  # This cell renders the button to amend the given resource.
  class WizardStepFormCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    def show
      render view
    end

    private

    def view_options
      model
    end

    def view
      view_options[:view]
    end

    def current_step
      view_options[:current_step]
    end

    def total_steps
      view_options[:total_steps]
    end

    def step?(step)
      current_step == step
    end

    # Returns the list with all the steps, in html
    def wizard_stepper
      content_tag :ol, class: "wizard__steps" do
        (1..total_steps).map { |step| wizard_stepper_step(step) }.join
      end
    end

    # Returns the list item of the given step, in html
    def wizard_stepper_step(step)
      content_tag(:li, wizard_step_name(step), class: wizard_step_classes(step))
    end

    # Returns the name of the step, translated
    def wizard_step_name(step)
      view_options[:steps][step.to_s.to_sym]
    end

    # Returns the css classes used for the proposal wizard for the desired step
    def wizard_step_classes(step)
      if step?(step)
        %(step--active step_#{step})
      elsif step < current_step
        %(step--past step_#{step})
      else
        %()
      end
    end

    # Returns the url to the back link
    def wizard_aside_back_url
      view_options[:wizard_aside_back_url]
    end

    # Returns the translation of the back button
    def i18n_wizard_aside_back
      t("decidim.wizard_step_form.wizard_aside.back")
    end

    # Returns the normal announcement
    def wizard_header_announcement
      view_options[:wizard_header_announcement]
    end

    # Returns the help text announcement
    def wizard_header_help_text
      view_options[:wizard_header_help_text]
    end

    def wizard_header_title
      view_options[:wizard_header_title]
    end

    def wizard_header_similar_resources_count
      "(#{view_options[:wizard_header_similar_resources_count]})"
    end

    # Returns a string with the current step number and the total steps number
    def wizard_header_see_steps
      content_tag(:span, class: "text-small") do
        i18n_wizard_header_step_of + " (#{wizard_header_see_steps_link})"
      end
    end

    def i18n_wizard_header_step_of
      t("decidim.wizard_step_form.wizard_header.step_of", current_step: current_step, total_steps: total_steps)
    end

    def wizard_header_see_steps_link
      content_tag(:a, t("decidim.wizard_step_form.wizard_header.see_steps"), "data-toggle": "steps")
    end
  end
end
