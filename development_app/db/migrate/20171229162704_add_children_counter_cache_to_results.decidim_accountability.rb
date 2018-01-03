# This migration comes from decidim_accountability (originally 20170623144902)
# frozen_string_literal: true

class AddChildrenCounterCacheToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_accountability_results, :children_count, :integer, default: 0
  end
end
