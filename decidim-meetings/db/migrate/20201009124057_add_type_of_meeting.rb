# frozen_string_literal: true

class AddTypeOfMeeting < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :type_of_meeting, :string, default: "in_person"
  end
end
