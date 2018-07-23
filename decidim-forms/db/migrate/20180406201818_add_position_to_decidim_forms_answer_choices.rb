# frozen_string_literal: true

class AddPositionToDecidimFormsAnswerChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_forms_answer_choices, :position, :integer
  end
end
