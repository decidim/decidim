# frozen_string_literal: true

class AlignFollowersBadgeScores < ActiveRecord::Migration[8.1]
  def up
    badge = Decidim::Gamification.find_badge(:followers)

    return unless badge

    Decidim::User.not_managed.not_deleted.find_each do |user|
      next unless badge.valid_for?(user)

      Decidim::Gamification.set_score(
        user,
        badge.name,
        badge.reset.call(user)
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
