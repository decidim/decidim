# frozen_string_literal: true

class AddMandatoryToFormsQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_forms_questions, :mandatory, :boolean
  end
end
