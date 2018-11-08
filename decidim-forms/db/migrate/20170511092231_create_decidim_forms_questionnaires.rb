# frozen_string_literal: true

class CreateDecidimFormsQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_forms_questionnaires do |t|
      t.jsonb :title
      t.jsonb :description
      t.jsonb :tos
      t.references :questionnaire_for, polymorphic: true, index: { name: "index_decidim_forms_questionnaires_questionnaire_for" }
      t.datetime :published_at

      t.timestamps
    end
  end
end
