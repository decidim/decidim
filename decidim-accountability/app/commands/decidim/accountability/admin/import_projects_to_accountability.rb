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

          ImportProjectsJob.perform_later(projects.pluck(:id), @form.current_component, @form.current_user)
          broadcast(:ok, projects.count)
        end

        private

        def projects
          Decidim::Budgets::Project.joins(:budget).selected.where(
            budget: { component: origin_component }
          ).reject { |item| @form.project_already_copied?(item) }
        end

        def origin_component
          @form.origin_component
        end
      end
    end
  end
end
