# frozen_string_literal: true

class AddNewFieldToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :has_conciliation_service, :boolean, null: false, default: false
    add_column :decidim_meetings_meetings, :conciliation_service_description, :jsonb
    add_column :decidim_meetings_meetings, :has_space_adapted_for_functional_diversity, :boolean, null: false, default: false
    add_column :decidim_meetings_meetings, :has_simultaneous_translations, :boolean, null: false, default: false
    add_column :decidim_meetings_meetings, :simultaneous_languages, :jsonb
  end
end
