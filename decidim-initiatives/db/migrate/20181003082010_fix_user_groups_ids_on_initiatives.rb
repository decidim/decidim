# frozen_string_literal: true

class FixUserGroupsIdsOnInitiatives < ActiveRecord::Migration[5.2]
  class UserGroup < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance

    default_scope { where(type: "Decidim::UserGroup") }
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
  end

  class InitiativesVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
  end

  # rubocop:disable Rails/SkipsModelValidations
  def change
    UserGroup.find_each do |group|
      old_id = group.extended_data["old_user_group_id"]
      next unless old_id

      Initiative
        .where(decidim_user_group_id: old_id)
        .update_all(decidim_user_group_id: group.id)
      InitiativesVote
        .where(decidim_user_group_id: old_id)
        .update_all(decidim_user_group_id: group.id)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
