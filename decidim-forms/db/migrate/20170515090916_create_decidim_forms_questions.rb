# frozen_string_literal: true

class CreateDecidimFormsQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_forms_questions do |t|
      t.jsonb :body
      t.references :decidim_questionnaire, index: true

      t.timestamps
    end
  end
end
