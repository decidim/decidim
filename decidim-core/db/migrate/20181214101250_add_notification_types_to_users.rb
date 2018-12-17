# frozen_string_literal: true

class AddNotificationTypesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :notification_types, :string, default: "all"
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::UserBaseEntity.update_all(notification_types: "all")
    # rubocop:enable Rails/SkipsModelValidations

    change_column_null :decidim_users, :notification_types, false
  end
end
