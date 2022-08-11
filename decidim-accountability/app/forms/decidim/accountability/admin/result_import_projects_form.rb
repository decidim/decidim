# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A form object to be used when admin users want to import a collection of projects
      # from another component into Accountability component.
      class ResultImportProjectsForm < Decidim::Form
        attribute :origin_component_id, Integer
        attribute :import_all_selected_projects, Boolean

        validates :origin_component_id, presence: true
        validates :import_all_selected_projects, allow_nil: false, acceptance: true
        validates :origin_projects_count, numericality: { greater_than: 0 }, if: ->(form) { form.origin_component_id }

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

        def selected_projects_count(component)
          projects = Decidim::Budgets::Project.joins(:budget).selected.where(
            budget: { component: }
          )
          projects.reject { |project| project_already_copied?(project) }.count
        end

        def project_already_copied?(original_project)
          original_project.linked_resources(:results, "included_projects").any? do |result|
            result.component == current_component
          end
        end

        private

        def origin_projects_count
          selected_projects_count(origin_component_id)
        end
      end
    end
  end
end
