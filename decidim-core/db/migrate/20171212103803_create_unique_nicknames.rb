# frozen_string_literal: true

class CreateUniqueNicknames < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
    include Decidim::Nicknamizable

    self.table_name = :decidim_users
  end

  def up
    add_column :decidim_users, :nickname, :string, limit: 20

    User.find_each do |user|
      user.update!(nickname: User.nicknamize(user.name))
    end

    add_index :decidim_users,
              :nickname,
              where: "(deleted_at IS NULL) AND (managed = 'f')",
              unique: true
  end

  def down
    remove_column :decidim_users, :nickname
  end
end
