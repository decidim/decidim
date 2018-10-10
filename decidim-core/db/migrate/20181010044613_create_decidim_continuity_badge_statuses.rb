# frozen_string_literal: true

class CreateDecidimContinuityBadgeStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_continuity_badge_statuses do |t|
      t.integer :current_streak, :integer, null: false, default: 0
      t.date :last_session_at, null: false
      t.references :subject, null: false, polymorphic: true, index: { name: "decidim_continuity_statuses_subject" }
    end
  end
end
