# frozen_string_literal: true

class CreateDecidimFormsQuestionConditions < ActiveRecord::Migration[5.1]
  def up
    create_table :decidim_forms_question_conditions do |t|
      t.references :decidim_forms_question, index: { name: "decidim_forms_question_condition" }
      t.integer :decidim_forms_question_condition_id, index: { name: "decidim_forms_question_condition_condition_question" }, null: false
      t.integer :condition_type, default: 0, null: false
      t.references :decidim_forms_answer_option, index: { name: "decidim_forms_question_condition_answer_option" }
      t.jsonb :condition_value
      t.boolean :mandatory, default: false

      t.timestamps
    end
  end

  def down
    drop_table :decidim_forms_question_conditions
  end
end
