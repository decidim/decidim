# This migration comes from decidim_participatory_processes (originally 20161025125300)
# frozen_string_literal: true

class AddPublishedAtToProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_processes, :published_at, :datetime, index: true
  end
end
