# frozen_string_literal: true

class AddMeetingTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :open_type, :string
    add_column :decidim_meetings_meetings, :open_type_other, :jsonb
    add_column :decidim_meetings_meetings, :public_type, :string
    add_column :decidim_meetings_meetings, :public_type_other, :jsonb
    add_column :decidim_meetings_meetings, :transparent_type, :string
    add_column :decidim_meetings_meetings, :transparent_type_other, :jsonb
  end
end
