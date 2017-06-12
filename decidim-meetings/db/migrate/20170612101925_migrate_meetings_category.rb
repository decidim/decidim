# frozen_string_literal: true

class MigrateMeetingsCategory < ActiveRecord::Migration[5.1]
  def change
    records = ActiveRecord::Base.connection.execute("SELECT id, decidim_category_id FROM decidim_meetings_meetings")
    values = records.map do |record|
      "(#{record[:id]}, #{record[:decidim_category_id]}, 'Decidim::Meetings::Meeting')"
    end
    if values.any?
      ActiveRecord::Base.connection.execute(
        "INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type) VALUES #{values.join(', ')}"
      )
    end
    remove_column :decidim_meetings_meetings, :decidim_category_id
  end
end
