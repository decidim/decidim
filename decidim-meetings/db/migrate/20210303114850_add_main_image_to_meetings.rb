# frozen_string_literal: true

class AddMainImageToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :main_image, :string
  end
end
