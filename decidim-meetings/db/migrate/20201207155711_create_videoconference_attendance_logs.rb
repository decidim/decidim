class CreateVideoconferenceAttendanceLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_meetings_videoconference_attendance_logs do |t|
      t.references :decidim_meeting, null: false, index: { name: :index_decidim_meetings_videoconference_attendance_logs_meeting }
      t.references :decidim_user, index: { name: :index_decidim_meetings_videoconference_attendance_logs_user }
      t.string :room_name, null: false
      t.string :user_videoconference_id, null: false, index: { name: :index_decidim_meetings_videoconference_attendance_logs_id }
      t.string :user_display_name
      t.string :event
      t.jsonb :extra, default: {}
      t.timestamps
    end
  end
end
