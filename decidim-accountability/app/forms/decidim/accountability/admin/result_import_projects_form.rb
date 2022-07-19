# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A form object to be used when admin users want to import a collection of projects
      # from another component into Accountability component.
      class ResultImportProjectsForm < Decidim::Form
        attribute :accountability_component_id, Integer
        attribute :budget_component_id, Integer

        validates :accountability_component_id, :budget_component_id, :accountability_component, presence: true

        def accountability_component_id
          current_component.id
        end

        def accountability_component
          Decidim::Component.find_by(id: accountability_component_id, manifest_name: "accountability")
        end

        def budget_components
          @budget_component ||= current_participatory_space.components.where(manifest_name: "budgets")
        end

        def budget_component
          @budget_component ||= current_participatory_space.components.find_by(id: budget_component_id)
        end

        def budget_components_collection
          budget_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end
      end
    end
  end
end
