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
    end
  end
end
