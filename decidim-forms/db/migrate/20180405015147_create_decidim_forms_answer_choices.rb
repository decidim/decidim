# frozen_string_literal: true

class CreateDecidimFormsAnswerChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_forms_answer_choices do |t|
      t.references :decidim_answer, index: { name: "index_decidim_forms_answer_choices_answer_id" }
      t.references :decidim_answer_option, index: { name: "index_decidim_forms_answer_choices_answer_option_id" }
      t.integer :position
      t.jsonb :body
      t.text :custom_body
    end
  end
end
