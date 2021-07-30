# frozen_string_literal: true

class AddSaltToElections < ActiveRecord::Migration[5.2]
  class Election < ApplicationRecord
    self.table_name = :decidim_elections_elections
  end

  def up
    add_column :decidim_elections_elections, :salt, :string, null: false, default: ""

    Election.find_each do |election|
      election.salt = Decidim::Tokenizer.random_salt
      election.save!
    end

    change_column_default(:decidim_elections_elections, :salt, nil)
  end

  def down
    remove_column :decidim_elections_elections, :salt
  end
end
