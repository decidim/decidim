# frozen_string_literal: true

class AddDescriptionToDecidimFormsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_forms_questions, :description, :jsonb
  end
end
