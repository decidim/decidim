# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class UpdateProjectSelection < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # selection - Defines if projects are selected (for implementation)
        # project_ids - the project ids to update.
        def initialize(selection, project_ids)
          @selection = selection
          @project_ids = project_ids
          @response = { selection_name: "", successful: [], errored: [] }
        end

        def call
          return broadcast(:invalid_selection) if @selection.blank? || [true, false, "true", "false"].exclude?(@selection)
          return broadcast(:invalid_project_ids) if @project_ids.blank?

          @selection = ActiveModel::Type::Boolean.new.cast(@selection)

          update_projects_selection

          broadcast(:update_projects_selection, @response)
        end

        private

        attr_reader :selection, :project_ids

        def update_projects_selection
          ::Decidim::Budgets::Project.where(id: project_ids).find_each do |project|
            if (selection == false && !project.selected?) || (selection && project.selected?)
              @response[:errored] << translated_attribute(project.title)
            else
              transaction do
                update_project_selection project
              end
              @response[:successful] << translated_attribute(project.title)
            end
          end
        end

        def update_project_selection(project)
          selected_at = selection ? Time.current : nil
          project.update!(
            selected_at:
          )
        end
      end
    end
  end
end
