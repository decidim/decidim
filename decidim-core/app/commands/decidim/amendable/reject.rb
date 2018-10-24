# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic to reject an amend.
    class Reject < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # amendable    - The resource that is being amended.
      def initialize(form)
        @form = form
        @amendment = form.amendment
        @amendable = form.amendable
        @emendation = form.emendation
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          @emendation.update state: "rejected"
          reject_amendment!

          # The proposal authors and followers are notified that the emendation has been rejected.
          notify_emendation_authors_and_followers
        end

        broadcast(:ok, @emendation)
      end

      private

      attr_reader :emendation, :form

      def reject_amendment!
        @amendment = Decidim.traceability.update!(
          @amendment,
          form.current_user,
          state: "rejected"
        )
      end

      def notify_emendation_authors_and_followers
        # # not implemented - to do!
        # recipients = @emendation.authors + @emendation.followers
        # Decidim::EventsManager.publish(
        #   event: "decidim.events.amends.amendment_rejected",
        #   event_class: Decidim::AmendmentRejectedEvent,
        #   resource: @emendation,
        #   recipient_ids: recipients.pluck(:id)
        # )
      end
    end
  end
end
