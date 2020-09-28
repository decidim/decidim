# frozen_string_literal: true

class AddMinSelectionsToDecidimElectionsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_questions, :min_selections, :integer, null: false, default: 1
  end
end
