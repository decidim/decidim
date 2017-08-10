# frozen_string_literal: true

class AddInscriptionAttributesToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :inscriptions_enabled, :boolean, null: false, default: false
    add_column :decidim_meetings_meetings, :available_slots, :integer, null: false, default: 0
    add_column :decidim_meetings_meetings, :inscription_terms, :jsonb
  end
end
