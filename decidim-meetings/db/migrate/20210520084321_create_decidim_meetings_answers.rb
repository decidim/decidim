# frozen_string_literal: true

class CreateDecidimMeetingsAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_meetings_answers do |t|
      t.references :decidim_user, index: true
      t.references :decidim_questionnaire, index: true
      t.references :decidim_question, index: { name: "index_decidim_meetings_answers_question_id" }

      t.timestamps
    end
  end
end
