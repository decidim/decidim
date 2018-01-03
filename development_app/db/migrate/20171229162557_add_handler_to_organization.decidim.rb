# This migration comes from decidim (originally 20170110153807)
# frozen_string_literal: true

class AddHandlerToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :twitter_handler, :string
  end
end
