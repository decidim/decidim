class SetEmailUniqueInOrganizationConditional < ActiveRecord::Migration[5.0]
  def change
    remove_index :decidim_users, ["email", "decidim_organization_id"]
    add_index :decidim_users, ["email", "decidim_organization_id"], where: "(deleted_at IS NULL)", name: "index_decidim_users_on_email_and_decidim_organization_id", unique: true, using: :btree
  end
end
