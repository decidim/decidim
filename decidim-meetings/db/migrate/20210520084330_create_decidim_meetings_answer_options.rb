# frozen_string_literal: true

class CreateDecidimMeetingsAnswerOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_meetings_answer_options do |t|
      t.references :decidim_question, index: { name: "index_decidim_meetings_answer_options_question_id" }
      t.jsonb :body
    end
  end
end
