# frozen_string_literal: true

class AddRelationBetweenSpeakerAndMeeting < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conference_speaker_conference_meetings do |t|
      t.belongs_to :conference_speaker, null: false, index: { name: "index_meetings_on_decidim_conference_speaker_id" }
      t.belongs_to :conference_meeting, null: false, index: { name: "index_meetings_on_decidim_conference_meeting_id" }
    end
  end
end
