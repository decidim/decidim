# frozen_string_literal: true

class AddPositionToFormsQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_forms_questions, :position, :integer, index: true
  end
end
