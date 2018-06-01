# frozen_string_literal: true

class CreateMeetingsQuestionnaires < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_questionnaires do |t|
      t.references :meeting, index: { name: :decidim_meetings_questionnaires_on_meeting_id }
      t.string :questionnaire_type, null: false
      t.jsonb :title
      t.jsonb :description
      t.jsonb :tos

      t.timestamps
    end
  end
end
