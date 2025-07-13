# frozen_string_literal: true

class AddRegisteredOnlyToDecidimShareTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_share_tokens, :registered_only, :boolean
  end
end
