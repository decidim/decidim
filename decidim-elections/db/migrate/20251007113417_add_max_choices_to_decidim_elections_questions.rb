# frozen_string_literal: true

class AddMaxChoicesToDecidimElectionsQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_elections_questions, :max_choices, :integer
  end
end
