# frozen_string_literal: true

class MoveUsersGroupsToUsersTable < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = "decidim_organizations"
  end

  class OldUserGroup < ApplicationRecord
    self.table_name = "decidim_user_groups"
  end

  class User < ApplicationRecord
    include Decidim::Nicknamizable

    self.table_name = "decidim_users"
  end

  class NewUserGroup < User
    include Decidim::Nicknamizable
  end

  class Membership < ApplicationRecord
    self.table_name = "decidim_user_group_memberships"
  end

  class Coauthorship < ApplicationRecord
    self.table_name = "decidim_coauthorships"
  end

  # rubocop:disable Rails/SkipsModelValidations
  def change
    add_column :decidim_users, :type, :string
    User.update_all(type: "Decidim::User")
    change_column_null(:decidim_users, :type, false)

    add_column :decidim_users, :extended_data, :jsonb, default: {}

    remove_index :decidim_users, %w(email decidim_organization_id)
    add_index(
      :decidim_users,
      %w(email decidim_organization_id),
      where: "((deleted_at IS NULL)  AND (managed = false) AND (type = 'Decidim::User'))",
      name: "index_decidim_users_on_email_and_decidim_organization_id",
      unique: true
    )

    User.reset_column_information
    NewUserGroup.reset_column_information

    new_ids = {}
    OldUserGroup.find_each do |old_user_group|
      clean_attributes = old_user_group.attributes.except(
        "id",
        "document_number",
        "phone",
        "rejected_at",
        "verified_at"
      )
      extended_data = {
        old_user_group_id: old_user_group.id,
        document_number: old_user_group.document_number,
        phone: old_user_group.phone,
        rejected_at: old_user_group.rejected_at,
        verified_at: old_user_group.verified_at
      }
      new_attributes = clean_attributes.merge(
        nickname: UserBaseEntity.nicknamize(clean_attributes["name"], old_user_group.decidim_organization_id),
        extended_data:
      )
      new_user_group = NewUserGroup.create!(new_attributes)
      new_ids[old_user_group.id] = new_user_group.id
    end

    User.where.not(type: "Decidim::User").update_all(type: "Decidim::UserGroup")

    new_ids.each do |old_id, new_id|
      Membership.where(decidim_user_group_id: old_id).update_all(decidim_user_group_id: new_id)
      Coauthorship.where(decidim_user_group_id: old_id).update_all(decidim_user_group_id: new_id)
    end

    drop_table :decidim_user_groups
  end
  # rubocop:enable Rails/SkipsModelValidations
end
