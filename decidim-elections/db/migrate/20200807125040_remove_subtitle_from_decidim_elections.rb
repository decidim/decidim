# frozen_string_literal: true

class RemoveSubtitleFromDecidimElections < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_elections_elections, :subtitle
  end
end
