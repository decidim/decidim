# frozen_string_literal: true

class AddOriginTitleToDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations_questions, :origin_title, :jsonb
    add_index :decidim_consultations_questions, :origin_title, name: "consultation_questions_origin_title_search"
  end
end
