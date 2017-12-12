# frozen_string_literal: true

require "decidim/migrators/username_to_nickname"

class CreateUniqueNicknames < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :nickname, :string, limit: 20

    reversible do |direction|
      direction.up { Decidim::Migrators::UsernameToNickname.new.migrate! }
    end

    add_index :decidim_users, :nickname, unique: true
  end
end
