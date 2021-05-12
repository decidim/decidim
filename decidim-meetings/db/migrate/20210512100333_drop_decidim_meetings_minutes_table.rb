# frozen_string_literal: true

class DropDecidimMeetingsMinutesTable < ActiveRecord::Migration[6.0]
  def up
    Decidim::ActionLog.where(resource_type: "Decidim::Meetings::Minutes").each do |action_log|
      minutes = minutes_class.find_by(id: action_log.resource_id)
      meeting = minutes.meeting
      version = action_log.version

      version_updates = {
        item_type: "Decidim::Meetings::Meeting",
        item_id: meeting.id
      }
      if version.object_changes.present?
        version_updates[:object_changes] = version.object_changes
                                                  .gsub("\ndescription:\n-\n-", "\nminutes_description:\n-\n-")
                                                  .gsub("\ndescription:\n-\n-", "\nminutes_description:\n-\n-")
      end

      # rubocop:disable Rails/SkipsModelValidations
      version.update_columns(version_updates)
      action_log.update_columns(
        resource_type: "Decidim::Meetings::Meeting",
        resource_id: meeting.id,
        action: "close"
      )
      # rubocop:enable Rails/SkipsModelValidations
    end

    drop_table :decidim_meetings_minutes
  end

  def down
    create_table :decidim_meetings_minutes do |t|
      t.references :decidim_meeting, index: true
      t.jsonb :description
      t.string :video_url
      t.string :audio_url
      t.boolean :visible

      t.timestamps
    end

    Decidim::Meetings::Meeting.find_each do |meeting|
      next if blank_minutes?(meeting)

      minutes_class.create!(
        decidim_meeting_id: meeting.id,
        description: meeting.minutes_description,
        video_url: meeting.video_url,
        audio_url: meeting.audio_url,
        visible: meeting.minutes_visible
      )
    end
  end
end

private

def blank_minutes?(meeting)
  meeting.video_url.blank? &&
    meeting.audio_url.blank? &&
    meeting.minutes_description.blank? || meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.all?(&:blank?)
end

def minutes_class
  Class.new(ApplicationRecord) do
    self.table_name = "decidim_meetings_minutes"
    def self.name
      "TmpMinutes"
    end

    belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
  end
end
