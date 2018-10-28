# frozen_string_literal: true

module Decidim
  module Gamification
    # This class is responsible to figure out the status of a user regarding
    # a certain badge.
    class BadgeStatus
      # Public: Initializes the `BadgeStatus`.
      #
      # user  - The user of whom to check the status.
      # badge - The badge for which to check the progress.
      #
      def initialize(user, badge)
        @user = user
        @badge = badge
      end

      # Public: Returns the current level of a user in a badge.
      #
      # Returns an Integer with the level.
      def level
        @badge.level_of(score)
      end

      # Public: Returns the score remaining to get to the next level.
      #
      # Returns an Integer with the remaining score.
      def next_level_in
        return nil if level >= @badge.levels.count
        @badge.levels[level] - score
      end

      # Public: Returns the score of a user on the badge.
      #
      # Returns an Integer with the score.
      def score
        @score ||= BadgeScore.find_by(user: @user, badge_name: @badge.name).try(:value) || 0
      end
    end
  end
end
