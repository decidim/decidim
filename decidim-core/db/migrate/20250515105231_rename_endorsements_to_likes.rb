class RenameEndorsementsToLikes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    rename_table :decidim_endorsements, :decidim_likes

    rename_index :decidim_likes, "idx_endorsements_authors", "idx_likes_authors"

    rename_index_if_exists(
      "index_decidim_endorsements_on_resource_type_and_resource_id",
      "index_decidim_likes_on_resource_type_and_resource_id"
    )

    rename_index_if_exists(
      "idx_endorsements_rsrcs_and_authors",
      "idx_likes_rsrcs_and_authors"
    )

    rename_index_if_exists(
      "index_decidim_endorsements_on_decidim_user_group_id",
      "index_decidim_likes_on_decidim_user_group_id"
    )
  end

  def down
    rename_table :decidim_likes, :decidim_endorsements

    rename_index :decidim_endorsements, "idx_likes_authors", "idx_endorsements_authors"

    rename_index_if_exists(
      "index_decidim_likes_on_resource_type_and_resource_id",
      "index_decidim_endorsements_on_resource_type_and_resource_id"
    )

    rename_index_if_exists(
      "idx_likes_rsrcs_and_authors",
      "idx_endorsements_rsrcs_and_authors"
    )

    rename_index_if_exists(
      "index_decidim_likes_on_decidim_user_group_id",
      "index_decidim_endorsements_on_decidim_user_group_id"
    )
  end

  private

  def rename_index_if_exists(old_name, new_name)
    return unless index_exists_by_name?(old_name)

    execute "ALTER INDEX #{old_name} RENAME TO #{new_name};"
  end

  def index_exists_by_name?(index_name)
    index = select_value <<~SQL
      SELECT to_regclass('#{index_name}')
    SQL
    index.present?
  end
end
