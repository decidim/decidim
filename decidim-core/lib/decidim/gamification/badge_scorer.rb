# frozen_string_literal: true

module Decidim
  module Gamification
    # This class is responsible of updating scores given a user and a badge. Will
    # also trigger any side-effects such as notifications.
    class BadgeScorer
      # Public: Initializes the class.
      #
      # user  - The user for which to update scores.
      # badge - The `Badge` to update.
      #
      def initialize(user, badge)
        @user = user
        @badge = badge
      end

      # Public: Increments the score for the user and badge.
      #
      # amount - Amount to increment. Defaults to 1.
      #
      # Returns a `BadgeScore`.
      def increment(amount = 1)
        raise InvalidAmountException unless amount.positive?

        with_level_tracking do
          BadgeScore.find_or_create_by(
            user: @user,
            badge_name: @badge.name
          ).increment(:value, amount).save!
        end
      end

      # Public: Decrements the score for the user and badge.
      #
      # amount - Amount to decrement. Defaults to 1.
      #
      # Returns a `BadgeScore`.
      def decrement(amount = 1)
        raise InvalidAmountException unless amount.positive?

        with_level_tracking do
          badge_score = BadgeScore.find_by(
            user: @user,
            badge_name: @badge.name
          )

          next if badge_score.blank?

          badge_score.decrement(:value, amount)
          badge_score.value = 0 if badge_score.value < 0
          badge_score.save!
        end
      end

      # Public: Sets the score for the user and badge.
      #
      # score - Score to set.
      #
      # Returns a `BadgeScore`.
      def set(score)
        raise NegativeScoreException if score.negative?

        with_level_tracking do
          BadgeScore.find_or_create_by(
            user_id: @user.id,
            badge_name: @badge.name
          ).update!(value: score)
        end
      end

      private

      class NegativeScoreException < StandardError; end
      class InvalidAmountException < StandardError; end

      def with_level_tracking
        previous_level = BadgeStatus.new(@user, @badge).level

        yield

        current_status = BadgeStatus.new(@user, @badge)
        send_notification(previous_level, current_status.level)
        current_status
      end

      def send_notification(previous_level, current_level)
        return unless current_level > previous_level

        if previous_level.zero?
          publish_event(name: "decidim.events.gamification.badge_earned",
                        klass: BadgeEarnedEvent,
                        previous_level: previous_level,
                        current_level: current_level)
        else
          publish_event(name: "decidim.events.gamification.level_up",
                        klass: LevelUpEvent,
                        previous_level: previous_level,
                        current_level: current_level)
        end
      end

      def publish_event(name:, klass:, previous_level:, current_level:)
        Decidim::EventsManager.publish(
          event: name,
          event_class: klass,
          resource: @user,
          recipient_ids: [@user.id],
          extra: {
            badge_name: @badge.name.to_s,
            previous_level: previous_level,
            current_level: current_level
          }
        )
      end
    end
  end
end
