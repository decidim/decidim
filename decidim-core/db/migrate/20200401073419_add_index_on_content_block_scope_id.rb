# frozen_string_literal: true

class AddIndexOnContentBlockScopeId < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :decidim_content_blocks,
      :scope_id,
      name: "idx_decidim_content_blocks_scope_id"
    )
  end
end
