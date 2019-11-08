# frozen_string_literal: true

class CreateDecidimConsultationsResponseGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_consultations_response_groups do |t|
      t.jsonb :title
      t.references :decidim_consultations_questions,
                   foreign_key: true,
                   index: { name: "index_consultations_response_groups_on_consultation_questions" }
      t.integer :responses_count,
                null: false,
                default: 0
      t.timestamps
    end
  end
end
