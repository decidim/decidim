class AddReferenceToMeetings < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_meetings_meetings, :reference, :string
    Decidim::Meetings::Meeting.find_each(&:save)
    change_column_null :decidim_meetings_meetings, :reference, false
  end
end
