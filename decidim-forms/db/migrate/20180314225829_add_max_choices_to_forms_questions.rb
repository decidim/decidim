# frozen_string_literal: true

class AddMaxChoicesToFormsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_forms_questions, :max_choices, :integer
  end
end
