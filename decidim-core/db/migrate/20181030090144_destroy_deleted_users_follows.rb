# frozen_string_literal: true

class DestroyDeletedUsersFollows < ActiveRecord::Migration[5.2]
  class Follow < ApplicationRecord
    self.table_name = "decidim_follows"
  end

  class User < ApplicationRecord
    self.table_name = "decidim_users"
  end

  def change
    deleted_users = Decidim::User.where.not(deleted_at: nil).pluck(:id)
    Follow.where(decidim_followable_type: "Decidim::UserBaseEntity", decidim_followable_id: deleted_users).destroy_all
    Follow.where(decidim_user_id: deleted_users).destroy_all
  end
end
