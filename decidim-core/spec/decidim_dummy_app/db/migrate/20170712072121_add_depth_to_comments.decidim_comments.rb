# This migration comes from decidim_comments (originally 20161214082645)
# frozen_string_literal: true

class AddDepthToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_comments_comments, :depth, :integer, null: false, default: 0
  end
end
