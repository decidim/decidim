# frozen_string_literal: true

class AddDirectMessageTypesToUsers < ActiveRecord::Migration[5.2]
  class UserBaseEntity < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance
  end

  def change
    add_column :decidim_users, :direct_message_types, :string, default: "all"
    # rubocop:disable-next Rails/SkipsModelValidations
    UserBaseEntity.update_all(direct_message_types: "all")

    change_column_null :decidim_users, :direct_message_types, false
  end
end
