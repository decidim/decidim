# frozen_string_literal: true

class AlignFollowersBadgeScores < ActiveRecord::Migration[8.1]
  # Since the user model is using STI, is hard insert a new class here that would
  # use the current badge behavior and also be a descendent of UserBaseEntity
  # Also, the set score may need to send in app notifications, therefore, we need
  # a Decidim::UserBaseEntity to be passed to the notification iself.
  def up
    badge = Decidim::Gamification.find_badge(:followers)

    return unless badge

    Decidim::User.not_managed.not_deleted.find_each do |user|
      next unless badge.valid_for?(user)

      score = badge.reset.call(user)
      badge_score = Decidim::Gamification::BadgeScore.find_by(user:, badge_name: badge.name)
      next if (badge_score&.value || 0) == score

      Decidim::Gamification.set_score(user, badge.name, score)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
