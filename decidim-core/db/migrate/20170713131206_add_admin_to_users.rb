class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_users, :admin, :boolean, null: false, default: false
    Decidim::User.where("roles @> ?", "{admin}").update_all(admin: true)
  end
end
