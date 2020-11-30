# frozen_string_literal: true

class AddVotesToDecidimElectionsAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_answers, :votes_count, :integer, default: 0, null: false
  end
end
