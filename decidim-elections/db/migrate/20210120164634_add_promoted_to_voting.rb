# frozen_string_literal: true

class AddPromotedToVoting < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votings, :promoted, :boolean, default: false, index: true
  end
end
