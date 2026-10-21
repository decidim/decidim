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
      Decidim::Gamification.set_score(user, badge.name, badge.reset.call(user)) if badge.valid_for?(user)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
