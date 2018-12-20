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
          update_amendable!
          notify_amendable_and_emendation_authors_and_followers
        end

        broadcast(:ok, @amendable)
      end

      private

      def accept_amendment!
        @amendment = Decidim.traceability.update!(
          @amendment,
          @amendable.creator_author,
          { state: "accepted" },
          visibility: "public-only"
        )
      end

      def update_amendable!
        @amendable = Decidim.traceability.update!(
          @amendable,
          emendation_author,
          amendable_attributes,
          visibility: "public-only"
        )
        @amendable.add_coauthor(@amender, user_group: nil)
      end

      def emendation_author
        return @emendation.creator.user_group if @emendation.creator.user_group
        @emendation.creator_author
      end

      def amendable_attributes
        {
          title: @form.title,
          body: @form.body
        }
      end

      def notify_amendable_and_emendation_authors_and_followers
        affected_users = @emendation.authors + @amendable.authors
        followers = @emendation.followers + @amendable.followers - affected_users

        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_accepted",
          event_class: Decidim::Amendable::AmendmentAcceptedEvent,
          resource: @emendation,
          affected_users: affected_users,
          followers: followers
        )
      end
    end
  end
end
