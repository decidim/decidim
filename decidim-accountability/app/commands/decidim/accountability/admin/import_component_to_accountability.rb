# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin imports projects from
      # one component to accountability.
      class ImportComponentToAccountability < Decidim::Command
        attr_reader :form

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless form.valid?

          job_class.perform_later(selected_items.pluck(:id), form.current_component, form.current_user)
          broadcast(:ok, selected_items.count)
        end

        private

        def selected_items
          form.filtered_items
        end

        def manifest_name
          form.origin_component.manifest_name
        end

        def job_class
          if manifest_name == "budgets"
            ImportProjectsJob
          elsif manifest_name == "proposals"
            ImportProposalsJob
          else
            raise "Invalid component"
          end
        end
      end
    end
  end
end
