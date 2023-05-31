# frozen_string_literal: true

module Decidim
  module Amendable
    # This cell functions as an intermediary cell that computes and passes the
    # necessary information, as a Hash, to Decidim::WizardStepFormCell.
    class WizardStepFormCell < Decidim::ViewModel
      def show
        cell("decidim/wizard_step_form", options_for_view)
      end

      private

      # Returns the current step as Integer.
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

      # Returns the translation for a given step.
      def i18n_step(step_number)
        t("decidim.amendments.wizard_step_form.steps.#{step_number}")
      end

      # Returns the name of the view we want to render, as Symbol.
      def view
        options[:view]
      end

      # Returns a Hash with all the data that will be needed in Decidim::WizardStepFormCell.
      def options_for_view
        common_options.merge(
          send("#{view}_options")
        )
      end

      # A Hash of data that is used in both :wizard_header and :wizard_aside views.
      def common_options
        {
          view:,
          current_step:,
          total_steps: 4,
          steps: {
            "1": i18n_step(1),
            "2": i18n_step(2),
            "3": i18n_step(3),
            "4": i18n_step(4)
          }
        }
      end

      # A Hash of data needed for the :wizard_aside view.
      def wizard_aside_options
        {
          wizard_aside_back_url:
        }
      end

      # A Hash of data needed for the :wizard_header view.
      def wizard_header_options
        {
          wizard_header_title:,
          wizard_header_similar_resources_count: options[:similar_resources_count],
          wizard_header_help_text:
        }
      end

      def amendable
        @amendable ||= model
      end

      def amendment
        @amendment ||= amendable.amendment
      end

      # Returns the link we want the back button to point to.
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

      # Returns the translation of the header title.
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

      # Returns a Hash that will be passed to a Decidim::AnnouncementCell.
      def wizard_header_help_text
        attribute = amendable.component.settings.amendments_wizard_help_text
        {
          announcement: translated_attribute(attribute).presence
        }
      end
    end
  end
end
