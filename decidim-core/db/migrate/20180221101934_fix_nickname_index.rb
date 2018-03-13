# frozen_string_literal: true

class FixNicknameIndex < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def change
    Decidim::User.where(nickname: nil)
                 .where(deleted_at: nil)
                 .where(managed: false)
                 .find_each { |u| u.update(nickname: Decidim::User.nicknamize(u.name)) }

    # rubocop:disable Rails/SkipsModelValidations
    Decidim::User.where(nickname: nil)
                 .update_all("nickname = ''")
    # rubocop:enable Rails/SkipsModelValidations

    change_column_default :decidim_users, :nickname, ""
    change_column_null(:decidim_users, :nickname, false)
  end
end
