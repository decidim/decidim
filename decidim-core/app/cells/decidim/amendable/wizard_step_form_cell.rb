# frozen_string_literal: true

module Decidim
  module Amendable
    # This cell renders the button to amend the given resource.
    class WizardStepFormCell < Decidim::ViewModel
      def show
        cell("decidim/wizard_step_form", options_for_view)
      end

      private

      def current_step
        @current_step ||= case params[:action].to_sym
                          when :new, :create
                            1
                          when :compare_draft
                            2
                          when :edit_draft, :update_draft, :destroy_draft
                            3
                          when :preview_draft, :publish_draft
                            4
                          end
      end

      def step?(step)
        current_step == step
      end

      def i18n_step(step_number)
        t("decidim.amendments.wizard_step_form.steps.#{step_number}")
      end

      def view
        options[:view]
      end

      def options_for_view
        common_options.merge(
          send("#{view}_options")
        )
      end

      def common_options
        {
          view: view,
          current_step: current_step,
          total_steps: 4,
          steps: {
            "1": i18n_step(1),
            "2": i18n_step(2),
            "3": i18n_step(3),
            "4": i18n_step(4)
          }
        }
      end

      def wizard_aside_options
        {
          wizard_aside_back_url: wizard_aside_back_url
        }
      end

      def wizard_header_options
        {
          wizard_header_title: wizard_header_title,
          wizard_header_similar_resources_count: options[:similar_resources_count],
          wizard_header_announcement: wizard_header_announcement,
          wizard_header_help_text: wizard_header_help_text
        }
      end

      def amendable
        @amendable ||= model
      end

      def amendment
        @amendment ||= amendable.amendment
      end

      def wizard_aside_back_url
        case current_step
        when 1
          Decidim::ResourceLocatorPresenter.new(amendable).path
        when 3
          Decidim::Core::Engine.routes.url_helpers.compare_draft_amend_path(amendment)
        when 4
          Decidim::Core::Engine.routes.url_helpers.edit_draft_amend_path(amendment)
        end
      end

      def wizard_header_title
        key = case current_step
              when 1
                :new
              when 2
                :compare_draft
              when 3
                :edit_draft
              when 4
                :preview_draft
              end

        t("decidim.amendments.#{key}.title")
      end

      def component
        amendable.component
      end

      def proposal_component?
        component.manifest_name == "proposals"
      end

      def wizard_header_announcement
        return {} unless proposal_component?
        return {} if step?(4)

        attribute = component.settings.new_proposal_help_text
        { announcement: translated_attribute(attribute).presence }
      end

      def wizard_header_help_text
        return {} unless proposal_component?

        attribute = component.settings.send("proposal_wizard_step_#{current_step}_help_text")
        callout_class = step?(2) ? "warning" : nil
        { announcement: translated_attribute(attribute).presence, callout_class: callout_class }
      end
    end
  end
end
