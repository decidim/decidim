# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process step in the system.
      class CreateParticipatoryProcessStep < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :description, :start_date, :end_date

        def attributes
          super.merge({
                        participatory_process: form.current_participatory_space,
                        active: form.current_participatory_space.steps.empty?
                      })
        end

        private

        def resource_class = Decidim::ParticipatoryProcessStep
      end
    end
  end
end
