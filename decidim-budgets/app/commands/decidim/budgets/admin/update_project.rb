# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user changes a Project from the admin
      # panel.
      class UpdateProject < Rectify::Command
        # Initializes an UpdateProject Command.
        #
        # form - The form from which to get the data.
        # project - The current instance of the project to be updated.
        def initialize(form, project)
          @form = form
          @project = project
        end

        # Updates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_project
            link_proposals
          end

          broadcast(:ok)
        end

        private

        attr_reader :project, :form

        def update_project
          project.update_attributes!(
            scope: form.scope,
            category: form.category,
            title: form.title,
            description: form.description,
            budget: form.budget
          )
        end

        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          project.link_resources(proposals, "included_proposals")
        end
      end
    end
  end
end
