# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to budget component.
      class ImportProposalsToBudgets < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(import_form, project_forms)
          @import_form = import_form
          @project_forms = project_forms
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @import_form.valid?
          return broadcast(:invalid) if @project_forms.empty?

          import_proposals

          broadcast(:ok)
        end

        private

        attr_reader :import_form, :project_forms

        def import_proposals
          @project_forms.each do |project_form|
            CreateProject.call(project_form)
          end
        end
      end
    end
  end
end
