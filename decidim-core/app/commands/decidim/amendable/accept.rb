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
        Decidim.traceability.perform_action!(
          :update,
          @amendable,
          emendation_author,
          visibility: "public-only"
        ) do
          @amendable.update!(amendable_attributes)
        end
      end

      def emendation_author
        return @emendation.creator.user_group if @emendation.creator.user_group
        @emendation.creator_author
      end

      def amendable_attributes
        {
          title: form.emendation_fields[:title],
          body: form.emendation_fields[:body]
        }
      end

      def notify_amendable_and_emendation_authors_and_followers
        recipients = @amendable.authors + @amendable.followers
        recipients += @emendation.authors + @emendation.followers
        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_accepted",
          event_class: Decidim::Amendable::AmendmentAcceptedEvent,
          resource: @emendation,
          recipient_ids: recipients.pluck(:id)
        )
      end
    end
  end
end
