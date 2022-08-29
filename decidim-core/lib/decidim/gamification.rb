# frozen_string_literal: true

module Decidim
  module Gamification
    autoload :Badge, "decidim/gamification/badge"
    autoload :BadgeRegistry, "decidim/gamification/badge_registry"
    autoload :BadgeStatus, "decidim/gamification/badge_status"
    autoload :BadgeScorer, "decidim/gamification/badge_scorer"
    autoload :BaseEvent, "decidim/gamification/base_event"
    autoload :BadgeEarnedEvent, "decidim/gamification/badge_earned_event"
    autoload :LevelUpEvent, "decidim/gamification/level_up_event"

    # Public: Returns a the status of a badge given a user and a badge name.
    #
    # Returns a `BadgeStatus` instance.
    def self.status_for(user, badge_name)
      return unless user.is_a?(Decidim::UserBaseEntity)

      BadgeStatus.new(user, find_badge(badge_name))
    end

    # Public: Increments the score of a user for a badge.
    #
    # user       - A User for whom to increase the score.
    # badge_name - The name of the badge for which to increase the score.
    # amount     - (Optional) The amount to increase. Defaults to 1.
    #
    # Returns nothing.
    def self.increment_score(user, badge_name, amount = 1)
      return unless amount.positive?
      return unless user.is_a?(Decidim::UserBaseEntity)

      BadgeScorer.new(user, find_badge(badge_name)).increment(amount)
    end

    # Public: Decrement the score of a user for a badge.
    #
    # user       - A User for whom to increase the score.
    # badge_name - The name of the badge for which to increase the score.
    # amount     - (Optional) The amount to decrease. Defaults to 1.
    #
    # Returns nothing.
    def self.decrement_score(user, badge_name, amount = 1)
      return unless amount.positive?
      return unless user.is_a?(Decidim::UserBaseEntity)

      BadgeScorer.new(user, find_badge(badge_name)).decrement(amount)
    end

    # Public: Sets the score of a user for a badge.
    #
    # user       - A User for whom to set the score.
    # badge_name - The name of the badge for which to increase the score.
    # score      - The score to set.
    #
    # Returns nothing.
    def self.set_score(user, badge_name, score)
      return unless user.is_a?(Decidim::UserBaseEntity)

      BadgeScorer.new(user, find_badge(badge_name)).set(score)
    end

    # Semi-private: The BadgeRegistry to register global badges to.
    def self.badge_registry
      @badge_registry ||= Decidim::Gamification::BadgeRegistry.new
    end

    # Public: Returns all available badges.
    #
    # Returns an Array<Badge>
    def self.badges
      badge_registry.all
    end

    # Public: Finds a Badge given a name.
    #
    # Returns a Badge if found, nil otherwise.
    def self.find_badge(name)
      badge_registry.find(name)
    end

    # Public: Registers a new Badge.
    #
    # Example:
    #
    #     Decidim.register_badge(:foo) do |badge|
    #       badge.levels = [1, 10, 50]
    #     end
    #
    # Returns nothing if registered successfully, raises an exception
    # otherwise.
    def self.register_badge(name, &)
      badge_registry.register(name, &)
    end

    # Public: Resets all the badge scores using each of the badges'
    # reset methods (if available). This is useful if the badges ever get
    # inconsistent.
    #
    # users - The Array of Users to reset the score.
    #
    # Returns nothing.
    def self.reset_badges(users = nil)
      return reset_badges(User.all) && reset_badges(UserGroup.all) unless users

      badges.each do |badge|
        Rails.logger.info "Resetting #{badge.name}..."

        if badge.reset
          users.find_each do |user|
            set_score(user, badge.name, badge.reset.call(user)) if badge.valid_for?(user)
          end
        else
          Rails.logger.info "Badge can't be reset since it doesn't have a reset method."
        end
      end
    end
  end
end
