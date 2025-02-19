# frozen_string_literal: true

class ConvertUserGroupsIntoUsers < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    self.table_name = "decidim_users"
    self.inheritance_column = nil

    scope :new_group, -> { where("extended_data @> ?", Arel.sql({ group: true }.to_json)) }
    scope :old_group, -> { where(type: "Decidim::UserGroup") }
  end

  class UserGroup < ApplicationRecord
    self.table_name = "decidim_users"
    self.inheritance_column = nil
  end

  # rubocop:disable Rails/SkipsModelValidations
  def up
    User.old_group.find_each do |group|
      group.update_attribute(:extended_data, (group.extended_data || {}).merge("group" => true))
      group.update_attribute(:type, "Decidim::User")
    end
  end

  def down
    User.new_group.find_each do |group|
      group.update_attribute(:type, "Decidim::UserGroup")
      group.update_attribute(:extended_data, (group.extended_data || {}).except("group"))
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
