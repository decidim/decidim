# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A form object to be used when admin users want to import a collection of projects
      # from another component into Accountability component.
      class ResultImportProjectsForm < Decidim::Form
        attribute :origin_component_id, Integer

        validates :origin_component_id, presence: true

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def origin_components
          @budgets_component ||= current_participatory_space.components.where(manifest_name: "budgets")
        end
      end
    end
  end
end
