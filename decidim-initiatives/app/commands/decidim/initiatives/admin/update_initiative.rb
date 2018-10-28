# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative.
      class UpdateInitiative < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative - Decidim::Initiative
        # form       - A form object with the params.
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
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            hashtag: form.hashtag,
            answer: form.answer,
            answer_url: form.answer_url
          }

          attrs[:answered_at] = Time.current if form.answer.present?

          if current_user.admin?
            attrs[:signature_start_date] = form.signature_start_date
            attrs[:signature_end_date] = form.signature_end_date
            attrs[:offline_votes] = form.offline_votes

            if initiative.published?
              @notify_extended = true if form.signature_end_date != initiative.signature_end_date &&
                                         form.signature_end_date > initiative.signature_end_date
            end
          end

          attrs
        end

        def notify_initiative_is_extended
          Decidim::EventsManager.publish(
            event: "decidim.events.initiatives.initiative_extended",
            event_class: Decidim::Initiatives::ExtendInitiativeEvent,
            resource: initiative,
            recipient_ids: initiative.followers.pluck(:id)
          )
        end
      end
    end
  end
end
