# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a phase in a participatory process as active (and
      # unsets a previous active phase)
      class ActivateParticipatoryProcessPhase < Decidim::Command
        # Public: Initializes the command.
        #
        # phase - A ParticipatoryProcessPhase that will be activated
        # current_user - the user performing the action
        def initialize(phase, current_user)
          @phase = phase
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if phase.nil? || phase.active?

          Decidim::ParticipatoryProcessPhase.transaction do
            deactivate_active_phases
            activate_phase
            notify_followers
            publish_phase_settings_change
          end

          broadcast(:ok)
        end

        private

        attr_reader :phase, :current_user

        def deactivate_active_phases
          phase.participatory_process.phases.where(active: true).each do |phase|
            @previous_phase = phase if phase.active?
            phase.update!(active: false)
          end
        end

        def activate_phase
          Decidim.traceability.perform_action!(
            :activate,
            phase,
            current_user
          ) do
            phase.update!(active: true)
          end
        end

        def notify_followers
          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.phase_activated",
            event_class: Decidim::ParticipatoryProcessPhaseActivatedEvent,
            resource: phase,
            followers: phase.participatory_process.followers
          )
        end

        def publish_phase_settings_change
          phase.participatory_process.components.each do |component|
            Decidim::SettingsChange.publish(
              component,
              previous_phase_settings(component).to_h,
              current_phase_settings(component).to_h
            )
          end
        end

        def current_phase_settings(component)
          component.phase_settings.fetch(phase.id.to_s)
        end

        def previous_phase_settings(component)
          return {} unless @previous_phase

          component.phase_settings.fetch(@previous_phase.id.to_s)
        end
      end
    end
  end
end
