# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic when a user or organization votes an initiative.
    class VoteInitiative < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        percentage_before = initiative.percentage

        Initiative.transaction do
          create_votes
        end

        percentage_after = initiative.reload.percentage

        send_notification
        notify_percentage_change(percentage_before, percentage_after)
        notify_support_threshold_reached(percentage_before, percentage_after)

        broadcast(:ok, votes)
      end

      attr_reader :votes

      private

      attr_reader :form

      delegate :initiative, to: :form

      def create_votes
        @votes = form.authorized_scopes.map do |scope|
          initiative.votes.create!(
            author: form.signer,
            encrypted_metadata: form.encrypted_metadata,
            timestamp: timestamp,
            hash_id: form.hash_id,
            scope: scope
          )
        end
      end

      def timestamp
        return unless timestamp_service

        @timestamp ||= timestamp_service.new(document: form.encrypted_metadata).timestamp
      end

      def timestamp_service
        @timestamp_service ||= Decidim.timestamp_service.to_s.safe_constantize
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.initiative_endorsed",
          event_class: Decidim::Initiatives::EndorseInitiativeEvent,
          resource: initiative,
          followers: initiative.author.followers
        )
      end

      def notify_percentage_change(before, after)
        percentage = [25, 50, 75, 100].find do |milestone|
          before < milestone && after >= milestone
        end

        return unless percentage

        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.milestone_completed",
          event_class: Decidim::Initiatives::MilestoneCompletedEvent,
          resource: initiative,
          affected_users: [initiative.author],
          followers: initiative.followers - [initiative.author],
          extra: {
            percentage: percentage
          }
        )
      end

      def notify_support_threshold_reached(before, after)
        # Don't need to notify if threshold has already been reached
        return if before == after || after != 100

        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.support_threshold_reached",
          event_class: Decidim::Initiatives::Admin::SupportThresholdReachedEvent,
          resource: initiative,
          followers: initiative.organization.admins
        )
      end
    end
  end
end
