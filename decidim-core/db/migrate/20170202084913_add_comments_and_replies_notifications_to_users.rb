class AddCommentsAndRepliesNotificationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :comments_notifications, :boolean, null: false
    add_column :decidim_users, :replies_notifications, :boolean, null: false
  end
end
