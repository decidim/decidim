# This migration comes from decidim_pages (originally 20161214150429)
# frozen_string_literal: true

class AddCommentableToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_pages_pages, :commentable, :boolean, null: false, default: false
  end
end
