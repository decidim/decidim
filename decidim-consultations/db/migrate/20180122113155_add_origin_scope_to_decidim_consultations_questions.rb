# frozen_string_literal: true

class AddOriginScopeToDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations_questions, :origin_scope, :jsonb
    add_index :decidim_consultations_questions, :origin_scope, name: "consultation_questions_origin_scope_search"
  end
end
