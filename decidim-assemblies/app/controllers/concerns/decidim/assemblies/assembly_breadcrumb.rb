# frozen_string_literal: true

module Decidim
  module Assemblies
    # Concern to provide a specific breadcrumb item to controllers using it
    module AssemblyBreadcrumb
      extend ActiveSupport::Concern

      private

      def current_participatory_space_breadcrumb_item
        return {} if current_participatory_space.blank?
        return super unless current_participatory_space.is_a?(Decidim::Assembly)

        items = current_participatory_space.ancestors.map do |participatory_space|
          {
            label: participatory_space.title,
            url: Decidim::ResourceLocatorPresenter.new(participatory_space).path,
            active: false,
            resource: participatory_space
          }
        end

        items << super
      end
    end
  end
end
