# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helpers related to the Participatory Process layout.
    module ParticipatoryProcessHelper
      include Decidim::FiltersHelper
      include Decidim::AttachmentsHelper
      include Decidim::IconHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::CheckBoxesTreeHelper

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
          image_url: block.images_container.attached_uploader(:background_image).variant_url(:big)
        )
      end

      # Items to display in the navigation of a process
      def process_nav_items(participatory_space)
        components = participatory_space
                     .components
                     .published.or(Decidim::Component.where(id: try(:current_component)))
                     .where(visible: true)

        [
          *(if participatory_space.members_public_page?
              [{
                name: t("member_menu_item", scope: "layouts.decidim.participatory_process_navigation"),
                url: decidim_participatory_processes.participatory_process_participatory_space_private_users_path(participatory_space),
                active: is_active_link?(decidim_participatory_processes.participatory_process_participatory_space_private_users_path(participatory_space), :inclusive)
              }]
            end
           )
        ] + components.map do |component|
          {
            id: component.id,
            name: decidim_escape_translated(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end.compact
      end

      def filter_sections
        items = [
          { method: :with_date, collection: filter_dates_values, label: t("decidim.participatory_processes.participatory_processes.filters.date"), id: "date" },
          { method: :with_any_type, collection: filter_types_values, label: t("decidim.participatory_processes.participatory_processes.filters.type"), id: "type" }
        ]
        available_taxonomy_filters.find_each do |taxonomy_filter|
          items.append(method: "with_any_taxonomies[#{taxonomy_filter.root_taxonomy_id}]",
                       collection: filter_taxonomy_values_for(taxonomy_filter),
                       label: decidim_sanitize_translated(taxonomy_filter.name),
                       id: "taxonomy")
        end
        items.reject { |item| item[:collection].blank? }
      end

      def available_taxonomy_filters
        Decidim::TaxonomyFilter.for(current_organization).for_manifest(:participatory_processes)
      end

      def process_types
        @process_types ||= Decidim::ParticipatoryProcessType.joins(:processes).distinct
      end

      def filter_types_values
        return if process_types.blank?

        type_values = process_types.map { |type| [type.id.to_s, translated_attribute(type.title)] }
        type_values.prepend(["", t("decidim.participatory_processes.participatory_processes.filters.names.all")])

        filter_tree_from_array(type_values)
      end

      def filter_dates_values
        flat_filter_values(:all, :upcoming, :past, :active, scope: "decidim.participatory_processes.participatory_processes.filters.names")
      end
    end
  end
end
