# frozen_string_literal: true

class ChangeDecidimElectionsTrusteesNameUniqueness < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_elections_trustees, :name, unique: true
  end
end
