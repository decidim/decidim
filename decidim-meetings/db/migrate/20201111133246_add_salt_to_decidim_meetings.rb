# frozen_string_literal: true

class AddSaltToDecidimMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :salt, :string
    # we leave old entries empty to maintain the old pad reference
  end
end
