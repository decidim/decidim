# frozen_string_literal: true

class AddFreeInstructiosnFieldToConsultationsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultations_questions, :instructions, :jsonb
  end
end
