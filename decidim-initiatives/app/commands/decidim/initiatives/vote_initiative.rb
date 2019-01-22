# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic when a user or organization votes an initiative.
    class VoteInitiative < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @initiative = form.initiative
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        build_initiative_vote

        percentage_before = @initiative.percentage
        vote.save!
        send_notification
        percentage_after = @initiative.reload.percentage

        notify_percentage_change(percentage_before, percentage_after)

        broadcast(:ok, vote)
      end

      attr_reader :vote

      private

      attr_reader :form, :current_user

      def build_initiative_vote
        @vote = @initiative.votes.build(
          author: @current_user,
          decidim_user_group_id: form.group_id
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
          affected_users: [@initiative.author],
          followers: @initiative.followers - [@initiative.author],
          extra: {
            percentage: percentage
          }
        )
      end
    end
  end
end
