# frozen_string_literal: true

class AddCommentsAvailabilityColumnsToDebatesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_debates_debates, :comments_enabled, :boolean, default: true
    reversible do |dir|
      dir.up do
        execute "UPDATE decidim_debates_debates set comments_enabled = true"
      end
    end
  end
end
