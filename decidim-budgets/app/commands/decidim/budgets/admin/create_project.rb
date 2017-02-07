# frozen_string_literal: true
module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates a Project from the admin
      # panel.
      class CreateProject < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_project
            link_proposals
          end

          broadcast(:ok)
        end

        private

        attr_reader :project

        def create_project
          @project = Project.create!(
            scope: @form.scope,
            category: @form.category,
            feature: @form.current_feature,
            title: @form.title,
            description: @form.description,
            budget: @form.budget
          )
        end

        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: @form.proposal_ids)
        end

        def link_proposals
          project.link_resources(proposals, "included_proposals")
        end
      end
    end
  end
end
