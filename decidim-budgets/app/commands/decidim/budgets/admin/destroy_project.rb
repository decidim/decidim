# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user deletes a Project from the admin
      # panel.
      class DestroyProject < Rectify::Command
        # Initializes an UpdateProject Command.
        #
        # project - The current instance of the project to be destroyed.
        # current_user - the user that performs the action
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
        end

        # Performs the action.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_project
          broadcast(:ok)
        end

        private

        attr_reader :project, :current_user

        def destroy_project
          Decidim.traceability.perform_action!(
            :delete,
            project,
            current_user
          ) do
            project.destroy!
          end
        end
      end
    end
  end
end
