# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic to answer
      # initiatives.
      class UpdateInitiativeAnswer < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative   - Decidim::Initiative
        # form         - A form object with the params.
        # current_user - Decidim::User
        def initialize(initiative, form, current_user)
          @form = form
          @initiative = initiative
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          @initiative = Decidim.traceability.update!(
            initiative,
            current_user,
            attributes
          )
          notify_initiative_is_extended if @notify_extended
          broadcast(:ok, initiative)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, initiative)
        end

        private

        attr_reader :form, :initiative, :current_user

        def attributes
          attrs = {
            answer: form.answer,
            answer_url: form.answer_url
          }

          attrs[:answered_at] = Time.current if form.answer.present?

          if form.signature_dates_required?
            attrs[:signature_start_date] = form.signature_start_date
            attrs[:signature_end_date] = form.signature_end_date

            if initiative.published? && form.signature_end_date != initiative.signature_end_date &&
               form.signature_end_date > initiative.signature_end_date
              @notify_extended = true
            end
          end

          attrs
        end

        def notify_initiative_is_extended
          Decidim::EventsManager.publish(
            event: "decidim.events.initiatives.initiative_extended",
            event_class: Decidim::Initiatives::ExtendInitiativeEvent,
            resource: initiative,
            followers: initiative.followers - [initiative.author]
          )
        end
      end
    end
  end
end
