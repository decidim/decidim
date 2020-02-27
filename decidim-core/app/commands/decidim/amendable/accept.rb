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
        @user_group = form.emendation.creator.user_group
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
          accept_amendment!
          update_amendable!
          notify_emendation_state_change!
          notify_amendable_and_emendation_authors_and_followers
        end

        broadcast(:ok, @emendation)
      end

      private

      attr_reader :form, :emendation

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
          @amender,
          form.emendation_params,
          visibility: "public-only"
        )
        @amendable.add_coauthor(@amender, user_group: @user_group)
      end

      def notify_emendation_state_change!
        emendation.process_amendment_state_change!
      end

      def notify_amendable_and_emendation_authors_and_followers
        affected_users = emendation.authors + @amendable.notifiable_identities
        followers = emendation.followers + @amendable.followers - affected_users

        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_accepted",
          event_class: Decidim::Amendable::AmendmentAcceptedEvent,
          resource: emendation,
          affected_users: affected_users.uniq,
          followers: followers.uniq
        )
      end
    end
  end
end
