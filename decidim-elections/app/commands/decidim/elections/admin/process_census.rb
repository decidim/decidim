# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class ProcessCensus < Decidim::Commands::UpdateResource
        def attributes
          {
            census_manifest: resource.census.name,
            census_settings: census_settings
          }
        end

        # This will run any post-processing hooks defined in the census manifest
        def run_after_hooks
          command = resource.census.after_update_command&.safe_constantize
          return unless command

          command.call(form, resource)
        end

        def census_settings
          return {} unless form.respond_to?(:census_settings)

          form.census_settings
        end
      end
    end
  end
end
