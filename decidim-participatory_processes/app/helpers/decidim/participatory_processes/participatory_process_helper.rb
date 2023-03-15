# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helpers related to the Participatory Process layout.
    module ParticipatoryProcessHelper
      include Decidim::FiltersHelper
      include Decidim::AttachmentsHelper
      include Decidim::IconHelper
      include Decidim::WidgetUrlsHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceReferenceHelper

      # Public: Returns the dates for a step in a readable format like
      # "01/01/2016 - 05/02/2016".
      #
      # participatory_process_step - The step to format to
      #
      # Returns a String with the formatted dates.
      def step_dates(participatory_process_step)
        dates = [participatory_process_step.start_date, participatory_process_step.end_date]
        dates.map { |date| date ? l(date.to_date, format: :decidim_short) : "?" }.join(" - ")
      end

      # Public: Returns the path for the participatory process cta button
      #
      # Returns a String with path.
      def participatory_process_cta_path(process)
        return participatory_process_path(process) if process.active_step&.cta_path.blank?

        path, params = participatory_process_path(process).split("?")

        "#{path}/#{process.active_step.cta_path}" + (params.present? ? "?#{params}" : "")
      end

      # Public: Returns the settings of a cta content block associated if
      # exists
      #
      # Returns a Hash with content block settings or nil
      def participatory_process_group_cta_settings(process_group)
        block = Decidim::ContentBlock.for_scope(
          :participatory_process_group_homepage,
          organization: current_organization
        ).find_by(
          manifest_name: "cta",
          scoped_resource_id: process_group.id
        )

        cta_settings = block&.settings

        return if cta_settings.blank? || cta_settings.button_url.blank?

        OpenStruct.new(
          text: translated_attribute(cta_settings.button_text),
          path: cta_settings.button_url,
          image_url: block.images_container.attached_uploader(:background_image).path(variant: :big)
        )
      end

      # Items to display in the navigation of a process
      def process_nav_items(participatory_space)
        components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        [
          {
            name: t("process_menu_item", scope: "layouts.decidim.process_navigation"),
            url: decidim_participatory_processes.participatory_process_path(participatory_space),
            active: is_active_link?(decidim_participatory_processes.participatory_process_path(participatory_space), :exclusive) ||
              is_active_link?(decidim_participatory_processes.all_metrics_participatory_process_path(participatory_space), :exclusive)
          }
        ] + components.map do |component|
          {
            name: translated_attribute(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end
      end
    end
  end
end
