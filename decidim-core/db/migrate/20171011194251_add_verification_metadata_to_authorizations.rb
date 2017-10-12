# frozen_string_literal: true

class AddVerificationMetadataToAuthorizations < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_authorizations, :verification_metadata, :jsonb, default: {}
  end

  def down
    remove_column :decidim_authorizations, :verification_metadata
  end
end
