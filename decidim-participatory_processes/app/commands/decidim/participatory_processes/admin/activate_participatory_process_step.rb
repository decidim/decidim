# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a step in a participatory process as active (and
      # unsets a previous active step)
      class ActivateParticipatoryProcessStep < Rectify::Command
        # Public: Initializes the command.
        #
        # step - A ParticipatoryProcessStep that will be activated
        # current_user - the user performing the action
        def initialize(step, current_user)
          @step = step
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if step.nil? || step.active?

          Decidim::ParticipatoryProcessStep.transaction do
            deactivate_active_steps
            activate_step
            notify_followers
            publish_step_settings_change
          end

          broadcast(:ok)
        end

        private

        attr_reader :step, :current_user

        def deactivate_active_steps
          step.participatory_process.steps.where(active: true).each do |step|
            @previous_step = step if step.active?
            step.update!(active: false)
          end
        end

        def activate_step
          Decidim.traceability.perform_action!(
            :activate,
            step,
            current_user
          ) do
            step.update!(active: true)
          end
        end

        def notify_followers
          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.step_activated",
            event_class: Decidim::ParticipatoryProcessStepActivatedEvent,
            resource: step,
            followers: step.participatory_process.followers
          )
        end

        def publish_step_settings_change
          step.participatory_process.components.each do |component|
            Decidim::SettingsChange.publish(
              component,
              previous_step_settings(component).to_h,
              current_step_settings(component).to_h
            )
          end
        end

        def current_step_settings(component)
          component.step_settings.fetch(step.id.to_s)
        end

        def previous_step_settings(component)
          return {} unless @previous_step

          component.step_settings.fetch(@previous_step.id.to_s)
        end
      end
    end
  end
end
