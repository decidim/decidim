# frozen_string_literal: true

module Decidim
  module Admin
    module ExportsHelper
      # Renders an export dropdown for the provided component, including an item
      # for each exportable artifact and format.
      #
      # component - The component to render the export dropdown for. Defaults to the
      #           current component.
      #
      # Returns a rendered dropdown.
      def export_dropdown(component = current_component, resource_id = nil)
        render partial: "decidim/admin/exports/dropdown", locals: { component:, resource_id: }
      end

      # Routes to the correct exporter for a component.
      #
      # component - The component to be routed.
      # options - Extra options that need to be passed to the route.
      #
      # Returns the path to the component exporter.
      def exports_path(component, options)
        EngineRouter.admin_proxy(component.participatory_space).component_exports_path(options.merge(component_id: component))
      end
    end
  end
end
