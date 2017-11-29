# frozen_string_literal: true

class AddStatusToAuthorizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_authorizations, :granted_at, :datetime

    execute "UPDATE decidim_authorizations SET granted_at = updated_at"
  end
end
