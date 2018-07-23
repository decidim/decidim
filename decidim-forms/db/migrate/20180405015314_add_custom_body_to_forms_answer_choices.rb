# frozen_string_literal: true

class AddCustomBodyToFormsAnswerChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_forms_answer_choices, :custom_body, :text
  end
end
