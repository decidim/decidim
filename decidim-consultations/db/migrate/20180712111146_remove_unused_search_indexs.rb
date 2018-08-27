# frozen_string_literal: true

class RemoveUnusedSearchIndexs < ActiveRecord::Migration[5.2]
  def change
    remove_index :decidim_consultations_questions, name: "consultation_questions_title_search"
    remove_index :decidim_consultations_questions, name: "consultation_questions_subtitle_search"
    remove_index :decidim_consultations_questions, name: "consultation_questions_what_is_decided_search"
    remove_index :decidim_consultations_questions, name: "consultation_question_promoter_group_search"
    remove_index :decidim_consultations_questions, name: "consultation_question_participatory_scope_search"
    remove_index :decidim_consultations_questions, name: "consultation_question_context_search"
  end
end
