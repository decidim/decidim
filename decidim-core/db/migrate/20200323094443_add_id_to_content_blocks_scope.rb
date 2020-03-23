# frozen_string_literal: true

class AddIdToContentBlocksScope < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_content_blocks, :scope_id, :integer
  end
end
