# frozen_string_literal: true

class AddSelectedToDecidimElectionsAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_answers, :selected, :boolean, null: false, default: false
  end
end
