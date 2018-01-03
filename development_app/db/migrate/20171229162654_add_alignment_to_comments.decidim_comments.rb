# This migration comes from decidim_comments (originally 20161216102820)
# frozen_string_literal: true

class AddAlignmentToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_comments_comments, :alignment, :integer, null: false, default: 0
  end
end
