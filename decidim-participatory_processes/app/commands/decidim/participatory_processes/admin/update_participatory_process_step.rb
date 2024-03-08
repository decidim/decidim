# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process step in the system.
      class UpdateParticipatoryProcessStep < Decidim::Commands::UpdateResource
        fetch_form_attributes :cta_path, :cta_text, :title, :start_date, :end_date, :description

        private

        def run_after_hooks
          return unless resource.saved_change_to_start_date || resource.saved_change_to_end_date

          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.step_changed",
            event_class: Decidim::ParticipatoryProcessStepChangedEvent,
            resource:,
            followers: resource.participatory_process.followers
          )
        end
      end
    end
  end
end
