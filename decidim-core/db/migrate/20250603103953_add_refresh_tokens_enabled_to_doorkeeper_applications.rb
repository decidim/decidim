# frozen_string_literal: true

class AddRefreshTokensEnabledToDoorkeeperApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_applications, :refresh_tokens_enabled, :boolean, default: false
  end
end
