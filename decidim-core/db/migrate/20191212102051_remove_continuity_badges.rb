# frozen_string_literal: true

class RemoveContinuityBadges < ActiveRecord::Migration[5.2]
  class BadgeScore < ApplicationRecord
    self.table_name = :decidim_gamification_badge_scores
  end

  def change
    drop_table :decidim_continuity_badge_statuses

    BadgeScore.where(badge_name: :continuity).delete_all
  end
end
