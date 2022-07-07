# frozen_string_literal: true

class DropDecidimMeetingsMinutesTable < ActiveRecord::Migration[6.0]
  class Minutes < ApplicationRecord
    self.table_name = "decidim_meetings_minutes"
  end

  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = :versions
  end

  class Meeting < ApplicationRecord
    self.table_name = "decidim_meetings_meetings"
  end

  def up
    ActionLog.where(resource_type: "Decidim::Meetings::Minutes").each do |action_log|
      minutes = Minutes.find_by(id: action_log.resource_id)
      version = Version.find_by(id: action_log.version_id)
      next unless minutes && version

      version_updates = {
        item_type: "Decidim::Meetings::Meeting",
        item_id: minutes.decidim_meeting_id
      }
      if version.object_changes.present?
        version_updates[:object_changes] = version.object_changes
                                                  .gsub("\ndescription:\n-\n-", "\nminutes_description:\n-\n-")
                                                  .gsub("\ndescription:\n-\n-", "\nminutes_description:\n-\n-")
      end

      version.update!(version_updates)
      action_log.update!(
        resource_type: "Decidim::Meetings::Meeting",
        resource_id: minutes.decidim_meeting_id,
        action: "close"
      )
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

    Meeting.find_each do |meeting|
      next if blank_minutes?(meeting)

      Minutes.create!(
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
  (meeting.video_url.blank? &&
    meeting.audio_url.blank? &&
    meeting.minutes_description.blank?) || (meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.all?(&:blank?))
end
