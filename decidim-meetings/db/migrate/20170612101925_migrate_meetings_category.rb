# frozen_string_literal: true

class MigrateMeetingsCategory < ActiveRecord::Migration[5.1]
  def change
    Decidim::Meetings::Meeting.find_each do |meeting|
      Decidim::Categorization.create!(
        decidim_category_id: meeting.category.id,
        categorizable: meeting
      )
    end
    remove_column :decidim_meetings_meetings, :decidim_category_id
  end
end
