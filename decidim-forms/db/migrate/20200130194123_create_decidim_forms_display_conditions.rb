# frozen_string_literal: true

class CreateDecidimFormsDisplayConditions < ActiveRecord::Migration[5.1]
  def up
    create_table :decidim_forms_display_conditions do |t|
      t.bigint :decidim_question_id, index: { name: "decidim_forms_display_condition_question" }, null: false
      t.bigint :decidim_condition_question_id, index: { name: "decidim_forms_display_condition_condition_question" }, null: false
      t.bigint :decidim_answer_option_id, index: { name: "decidim_forms_display_condition_answer_option" }
      t.integer :condition_type, default: 0, null: false
      t.jsonb :condition_value
      t.boolean :mandatory, default: false

      t.timestamps
    end
  end

  def down
    drop_table :decidim_forms_display_conditions
  end
end
