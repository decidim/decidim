# frozen_string_literal: true

class AddBadgeScores < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_gamification_badge_scores do |t|
      t.references :user, null: false
      t.string :badge_name, null: false
      t.integer :value, null: false, default: 0
    end
  end
end
