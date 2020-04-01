# frozen_string_literal: true

class AddIndexOnContentBlockScopeId < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :decidim_content_blocks,
      :scope_id,
      unique: true,
      name: "idx_decidim_content_blocks_unique_scope_id",
      where: "scope_id IS NOT null"
    )
  end
end
