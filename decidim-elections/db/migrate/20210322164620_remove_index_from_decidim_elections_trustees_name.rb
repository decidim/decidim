# frozen_string_literal: true

class RemoveIndexFromDecidimElectionsTrusteesName < ActiveRecord::Migration[5.2]
  def change
    remove_index :decidim_elections_trustees, name: "index_decidim_elections_trustees_on_name"
  end
end
