# frozen_string_literal: true

class CreateDecidimConsultationsResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_consultations_responses do |t|
      t.jsonb :title
      t.references :decidim_consultations_questions,
                   foreign_key: true,
                   index: { name: "index_consultations_responses_on_consultation_questions" }

      t.timestamps
    end
  end
end
