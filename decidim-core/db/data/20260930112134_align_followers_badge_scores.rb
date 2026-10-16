# frozen_string_literal: true

class AlignFollowersBadgeScores < ActiveRecord::Migration[8.1]
  def up
    badge = Decidim::Gamification.find_badge(:followers)

    return unless badge

    Decidim::User.not_managed.not_deleted.find_each do |user|
      next unless badge.valid_for?(user)

      score = badge.reset.call(user)
      badge_score = Decidim::Gamification::BadgeScore.find_by(
        user_id: user.id,
        badge_name: badge.name
      )

      next if score.zero? && badge_score.blank?
      next if badge_score&.value == score

      Decidim::Gamification.set_score(
        user,
        badge.name,
        score
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
