# frozen_string_literal: true

class RemoveLegacyImagesFromCoreModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_organizations, :logo, :string
    remove_column :decidim_organizations, :official_img_footer, :string
    remove_column :decidim_organizations, :favicon, :string

    remove_column :oauth_applications, :organization_logo, :string

    remove_column :decidim_authorizations, :verification_attachment, :string

    # The original decidim_attachments table creation was in decidim-participatory_processes
    # at decidim-participatory_processes/db/migrate/20161116115156_create_attachments.rb
    #
    # We need to workaround this issue as when creating new application this table may not exist
    # when this migration is run
    remove_column :decidim_attachments, :file, :string if table_exists?(:decidim_attachments)

    remove_column :decidim_users, :avatar, :string

    remove_column :decidim_private_exports, :file, :string
  end
end
