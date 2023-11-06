# frozen_string_literal: true

module Decidim
  module Assemblies
    # Concern to provide a specific breadcrumb item to controllers using it
    module AssemblyBreadcrumb
      extend ActiveSupport::Concern

      private

      def current_participatory_space_breadcrumb_item
        return {} if current_participatory_space.blank?

        dropdown_cell = current_participatory_space_manifest.breadcrumb_cell

        items = current_participatory_space.ancestors.map do |participatory_space|
          {
            label: participatory_space.title,
            url: Decidim::ResourceLocatorPresenter.new(participatory_space).path,
            active: false,
            dropdown_cell:,
            resource: participatory_space
          }
        end

        items << {
          label: current_participatory_space.title,
          url: Decidim::ResourceLocatorPresenter.new(current_participatory_space).path,
          active: true,
          dropdown_cell:,
          resource: current_participatory_space
        }
      end
    end
  end
end
