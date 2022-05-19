# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class UpdateProjectCategory < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # category_id - the category id to update
        # project_ids - the project ids to update.
        def initialize(category_id, project_ids)
          @category = Decidim::Category.find_by id: category_id
          @project_ids = project_ids
          @response = { category_name: "", successful: [], errored: [] }
        end

        def call
          return broadcast(:invalid_category) if @category.blank?
          return broadcast(:invalid_project_ids) if @project_ids.blank?

          @response[:category_name] = @category.translated_name
          Project.where(id: @project_ids).find_each do |project|
            if @category == project.category
              @response[:errored] << translated_attribute(project.title)
            else
              transaction do
                update_project_category project
              end
              @response[:successful] << translated_attribute(project.title)
            end
          end

          broadcast(:update_projects_category, @response)
        end

        private

        def update_project_category(project)
          project.update!(
            category: @category
          )
        end
      end
    end
  end
end
