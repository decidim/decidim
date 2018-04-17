# frozen_string_literal: true

class AddResponsesCountToDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations_questions, :responses_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up { initialize_counter }
    end
  end

  def initialize_counter
    execute <<-SQL.squish
      UPDATE decidim_consultations_questions
         SET responses_count = (
           select count(1)
           from decidim_consultations_responses
           where decidim_consultations_questions_id = decidim_consultations_questions.id
         )
    SQL
  end
end
