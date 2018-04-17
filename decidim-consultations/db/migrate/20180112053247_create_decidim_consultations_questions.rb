# frozen_string_literal: true

class CreateDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_consultations_questions do |t|
      t.references :decidim_consultation, index: { name: "index_consultations_questions_on_consultation_id" }
      t.references :decidim_scope

      t.jsonb :title, null: false
      t.jsonb :subtitle, null: false
      t.jsonb :what_is_decided, null: false
      t.jsonb :promoter_group, null: false
      t.jsonb :participatory_scope, null: false
      t.jsonb :question_context

      # Text search indexes for consultation questions.
      t.index :title, name: "consultation_questions_title_search"
      t.index :subtitle, name: "consultation_questions_subtitle_search"
      t.index :what_is_decided, name: "consultation_questions_what_is_decided_search"
      t.index :promoter_group, name: "consultation_question_promoter_group_search"
      t.index :participatory_scope, name: "consultation_question_participatory_scope_search"
      t.index :question_context, name: "consultation_question_context_search"

      t.string :banner_image
      t.string :introductory_video_url
      t.string :reference
      t.string :hashtag

      # Publicable
      t.datetime :published_at, index: true

      t.timestamps
    end
  end
end
