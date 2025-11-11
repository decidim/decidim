# frozen_string_literal: true

class ConvertUserGroupsIntoUsers < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

    self.table_name = "decidim_users"
    self.inheritance_column = nil

    scope :new_group, -> { where("extended_data @> ?", { group: true }.to_json) }
    scope :old_group, -> { where(type: "Decidim::UserGroup") }

    def verified_at
      extended_data["verified_at"]
    end
  end

  class UserGroup < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

    self.table_name = "decidim_users"
    self.inheritance_column = nil
  end

  # Identify if there is another user with the same email in the same organization
  # @param [User] group
  # @return [Boolean]
  def another_user_with_same_email_in_organization?(group)
    User.where.not(id: group.id).exists?(decidim_organization_id: group.decidim_organization_id, email: group.email)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def up
    User.old_group.find_each do |group|
      if group.email.blank? || another_user_with_same_email_in_organization?(group)
        group.update_attribute(:email, "user_group_#{group.id}@#{group.organization.host}.invalid")
        group.update_attribute(:extended_data, (group.extended_data || {}).merge("patched" => true, "previous_email" => group.email))

        group.reload
      end

      group.update_attribute(:extended_data, (group.extended_data || {}).merge("group" => true))
      group.update_attribute(:type, "Decidim::User")
      group.update_attribute(:officialized_at, group.verified_at) if group.verified_at.present?
    end
  end

  def down
    User.new_group.find_each do |group|
      group.update_attribute(:officialized_at, nil)
      group.update_attribute(:type, "Decidim::UserGroup")
      group.update_attribute(:extended_data, (group.extended_data || {}).except("group"))
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
