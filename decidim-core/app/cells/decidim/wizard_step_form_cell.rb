# frozen_string_literal: true

module Decidim
  # This cell renders the wizard step form :wizard_aside or :wizard_header view.
  # Is designed to be used by different models and so it does not try to compute
  # the information likely to change. Expects a Hash with all necessary data.
  class WizardStepFormCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    def show
      render view
    end

    private

    # A Hash with all necessary data to render the view.
    def view_options
      model
    end

    # Returns the name of the view we want to render, as Symbol.
    def view
      view_options[:view]
    end

    # Returns the current step as Integer.
    def current_step
      view_options[:current_step]
    end

    # Returns the total number of steps to build the #wizard_stepper, as Integer.
    def total_steps
      view_options[:total_steps]
    end

    # Returns the list with all the steps, in HTML.
    def wizard_stepper
      content_tag :ol, class: "wizard__steps" do
        (1..total_steps).map { |step| wizard_stepper_step(step) }.join
      end
    end

    # Returns the list item of the given step, in HTML.
    def wizard_stepper_step(step)
      attributes = { class: wizard_step_classes(step) }
      attributes[:"aria-current"] = "step" if step == current_step

      content_tag(:li, wizard_step_name(step), attributes)
    end

    # Returns the name of the step, translated
    def wizard_step_name(step)
      view_options[:steps][step.to_s.to_sym]
    end

    # Returns the CSS classes used for the wizard for the given step.
    def wizard_step_classes(step)
      if step == current_step
        %(step--active step_#{step})
      elsif step < current_step
        %(step--past step_#{step})
      else
        %()
      end
    end

    # Returns the url of the back button.
    def wizard_aside_back_url
      view_options[:wizard_aside_back_url]
    end

    # Returns the translation of the back button.
    def i18n_wizard_aside_back
      t(".wizard_aside.back")
    end

    # Returns a Hash to be passed to Decidim::AnnouncementCell.
    def wizard_header_announcement
      view_options[:wizard_header_announcement] || {}
    end

    # Returns a Hash to be passed to Decidim::AnnouncementCell.
    def wizard_header_help_text
      view_options[:wizard_header_help_text] || {}
    end

    # Returns the translation of the header title.
    def wizard_header_title
      view_options[:wizard_header_title]
    end

    # Returns the similar resources count for the compare step.
    def wizard_header_similar_resources_count
      count = view_options[:wizard_header_similar_resources_count]
      "(#{count})" if count
    end

    # Returns the header see steps information, only visible for small screens.
    def wizard_header_see_steps
      content_tag(:span, class: "text-small") do
        i18n_wizard_header_step_of + " (#{wizard_header_see_steps_link})"
      end
    end

    # Returns a translation with the current step number and the total steps number.
    def i18n_wizard_header_step_of
      t(".wizard_header.step_of", current_step:, total_steps:)
    end

    # Returns a link that toggles the steps in the mobile view.
    def wizard_header_see_steps_link
      content_tag(:a, t(".wizard_header.see_steps"), "data-toggle": "steps")
    end
  end
end
