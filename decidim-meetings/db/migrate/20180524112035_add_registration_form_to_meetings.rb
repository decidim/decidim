# frozen_string_literal: true

class AddRegistrationFormToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :registration_form_id, :integer
  end
end
