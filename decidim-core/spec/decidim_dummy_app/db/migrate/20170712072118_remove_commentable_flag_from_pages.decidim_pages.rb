# This migration comes from decidim_pages (originally 20170110145040)
# frozen_string_literal: true

class RemoveCommentableFlagFromPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_pages_pages, :commentable
  end
end
