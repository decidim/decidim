# frozen_string_literal: true

class AddNicknameToManagedUsers < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def up
    User.where(managed: true, nickname: nil).includes(:organization).find_each do |user|
      user.nickname = UserBaseEntity.nicknamize(user.name, user.decidim_organization_id)
      user.save
    end
  end
end
