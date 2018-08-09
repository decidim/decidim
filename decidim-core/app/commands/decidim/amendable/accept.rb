# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic to accept an amend.
    class Accept < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # amendable    - The resource that is being amended.
      def initialize(form)
        @form = form
        @amendment = form.amendment
        @amendable = form.amendable
        @emendation = form.emendation
        @amender = form.emendation.creator_author
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?

        transaction do

          accept_amendment!
          accept_emendation!
          update_amendable!

          # The amendable and emendation authors and followers are notified that the emendation has been accepted.
          notify_amendable_and_emendation_authors_and_followers
        end

        broadcast(:ok, @amendable)
      end

      private

      attr_reader :amender, :form

      def accept_amendment!
        @amendment = Decidim.traceability.update!(
          @amendment,
          form.current_user,
          state: "accepted"
        )
      end

      def accept_emendation!
        @emendation = Decidim.traceability.update!(
          @emendation,
          form.current_user,
          state: "accepted"
        )
      end

      def update_amendable!
        # @amendable = Decidim.traceability.update!(
        #   @amendable,
        #   form.current_user,
        #   amendable_attributes
        # )
        @amendable.update!(
          amendable_attributes
        )
        @amendable.add_coauthor(amender, user_group: nil)
      end

      def amendable_attributes
        {
          title: form.title,
          body: form.body
        }
      end

      def notify_amendable_and_emendation_authors_and_followers
        # # not implemented - to do!
        # recipients = @amendable.authors + @amendable.followers
        # recipients += @emendation.authors + @emendation.followers
        # Decidim::EventsManager.publish(
        #   event: "decidim.events.amends.amendment_accepted",
        #   event_class: Decidim::AmendmentAcceptedEvent,
        #   resource: @emendation,
        #   recipient_ids: recipients.pluck(:id)
        # )
      end
    end
  end
end
