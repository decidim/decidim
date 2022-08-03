# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin imports projects from
      # one component to accountability.
      class ImportProjectsToAccountability < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          qeued_projects = @form.to_be_added_projects
          import_job = ImportProjectsJob.new(@form)
          transaction do
            import_job.results_from_projects!(projects)
            import_job.notify_user!
          end
          broadcast(:ok, qeued_projects)
        end

        private

        def projects
          Decidim::Budgets::Project.joins(:budget).selected.where(
            budget: { component: origin_component }
          )
        end

        def origin_component
          @form.origin_component
        end
      end
    end
  end
end
