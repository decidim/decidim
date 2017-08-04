# frozen_string_literal: true

module Decidim
  module Admin
    module ExportsHelper
      # Renders an export dropdown for the provided feature, including an item
      # for each exportable artifact and format.
      #
      # feature - The feature to render the export dropdown for. Defaults to the
      #           current feature.
      #
      # Returns a rendered dropdown.
      def export_dropdown(feature = current_feature)
        render partial: "decidim/admin/exports/dropdown", locals: { feature: feature }
      end

      # Routes to the correct exporter for a feature.
      #
      # feature - The feature to be routed.
      # options - Extra options that need to be passed to the route.
      #
      # Returns the path to the feature exporter.
      def exports_path(feature, options)
        EngineRouter.admin_proxy(feature.participatory_space).feature_exports_path(options.merge(feature_id: feature))
      end
    end
  end
end
