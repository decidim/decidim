# This migration comes from decidim (originally 20160920141039)
# frozen_string_literal: true

class UserBelongsToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_reference :decidim_users, :decidim_organization, index: true, foreign_key: true
  end
end
