# This migration comes from decidim_meetings (originally 20170215132546)
# frozen_string_literal: true

class AddReferenceToMeetings < ActiveRecord::Migration[5.0]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
  end

  def change
    add_column :decidim_meetings_meetings, :reference, :string
    Meeting.find_each(&:save)
    change_column_null :decidim_meetings_meetings, :reference, false
  end
end
