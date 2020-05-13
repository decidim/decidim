# frozen_string_literal: true

class AddMatrixRowIdToDecidimFormsAnswerChoices < ActiveRecord::Migration[5.2]
  class AnswerChoice < ApplicationRecord
    self.table_name = :decidim_forms_answer_choices
  end

  def change
    add_column :decidim_forms_answer_choices, :decidim_question_matrix_row_id, :integer
  end
end
