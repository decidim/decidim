# frozen_string_literal: true

class AddNotificationTypesToUsers < ActiveRecord::Migration[5.2]
  class UserBaseEntity < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance
  end

  def change
    add_column :decidim_users, :notification_types, :string, default: "all"
    # rubocop:disable Rails/SkipsModelValidations
    UserBaseEntity.update_all(notification_types: "all")
    # rubocop:enable Rails/SkipsModelValidations

    change_column_null :decidim_users, :notification_types, false
  end
end
