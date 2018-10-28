# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process in the system.
      class UpdateParticipatoryProcessStep < Rectify::Command
        attr_reader :step
        # Public: Initializes the command.
        #
        # step - the ParticipatoryProcessStep to update
        # form - A form object with the params.
        def initialize(step, form)
          @step = step
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_step
          notify_followers
          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_step
          Decidim.traceability.update!(
            step,
            form.current_user,
            attributes
          )
        end

        def attributes
          {
            cta_path: form.cta_path,
            cta_text: form.cta_text,
            title: form.title,
            start_date: form.start_date,
            end_date: form.end_date,
            description: form.description
          }
        end

        def notify_followers
          return unless step.saved_change_to_start_date || step.saved_change_to_end_date

          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.step_changed",
            event_class: Decidim::ParticipatoryProcessStepChangedEvent,
            resource: step,
            recipient_ids: step.participatory_process.followers.pluck(:id)
          )
        end
      end
    end
  end
end
