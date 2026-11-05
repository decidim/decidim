# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process phase in the system.
      class UpdateParticipatoryProcessPhase < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :start_date, :end_date, :description

        private

        def run_after_hooks
          return unless resource.saved_change_to_start_date || resource.saved_change_to_end_date

          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.phase_changed",
            event_class: Decidim::ParticipatoryProcessPhaseChangedEvent,
            resource:,
            followers: resource.participatory_process.followers
          )
        end
      end
    end
  end
end
