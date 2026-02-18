# frozen_string_literal: true

class FixNicknameIndex < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users

    include Decidim::Nicknamizable
  end

  def change
    User.where(nickname: nil)
        .where(deleted_at: nil)
        .where(managed: false)
        .find_each { |u| u.update(nickname: UserBaseEntity.nicknamize(u.name, u.decidim_organization_id)) }

    # rubocop:disable Rails/SkipsModelValidations
    User.where(nickname: nil).update_all("nickname = ''")
    # rubocop:enable Rails/SkipsModelValidations

    change_column_default :decidim_users, :nickname, ""
    change_column_null(:decidim_users, :nickname, false)
  end
end
