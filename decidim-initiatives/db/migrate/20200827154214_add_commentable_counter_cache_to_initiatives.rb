# frozen_string_literal: true

class AddCommentableCounterCacheToInitiatives < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Initiative.reset_column_information
    Decidim::Initiative.find_each(&:update_comments_count)
  end
end
