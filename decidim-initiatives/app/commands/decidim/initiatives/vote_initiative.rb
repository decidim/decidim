# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic when a user or organization votes an initiative.
    class VoteInitiative < Rectify::Command
      # Public: Initializes the command.
      #
      # initiative   - A Decidim::Initiative object.
      # current_user - The current user.
      # group_id     - Decidim user group id
      def initialize(initiative, current_user, group_id)
        @initiative = initiative
        @current_user = current_user
        @decidim_user_group_id = group_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        build_initiative_vote
        return broadcast(:invalid) unless vote.valid?

        percentage_before = @initiative.percentage
        vote.save!
        send_notification
        percentage_after = @initiative.reload.percentage

        notify_percentage_change(percentage_before, percentage_after)

        broadcast(:ok, vote)
      end

      attr_reader :vote

      private

      def build_initiative_vote
        @vote = @initiative.votes.build(
          author: @current_user,
          decidim_user_group_id: @decidim_user_group_id
        )
      end

      def send_notification
        return if vote.user_group.present?

        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.initiative_endorsed",
          event_class: Decidim::Initiatives::EndorseInitiativeEvent,
          resource: @initiative,
          followers: @initiative.author.followers
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
          resource: @initiative,
          recipient_ids: @initiative.followers.pluck(:id),
          extra: {
            percentage: percentage
          }
        )
      end
    end
  end
end
