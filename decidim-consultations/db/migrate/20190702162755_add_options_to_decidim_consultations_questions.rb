# frozen_string_literal: true

class AddOptionsToDecidimConsultationsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultations_questions, :max_responses, :integer
    add_column :decidim_consultations_questions, :min_responses, :integer
  end
end
