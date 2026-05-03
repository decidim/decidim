# frozen_string_literal: true

class RemoveLegacyImagesFromCoreModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_organizations, :logo, :string
    remove_column :decidim_organizations, :official_img_footer, :string
    remove_column :decidim_organizations, :favicon, :string

    remove_column :oauth_applications, :organization_logo, :string

    remove_column :decidim_authorizations, :verification_attachment, :string

    # The original decidim_attachments table creation was in decidim-participatory_processes
    # and then it was made polymorphic.
    # We need to workaround this issue as when creating new application this table may not exist
    # when this migration is run. To be in a consistent state for new apps, we also do this in decidim-participatory_processes
    #
    # @see decidim-participatory_processes/db/migrate/20161116115156_create_attachments.rb
    # @see decidim-participatory_processes/db/migrate/20170123134023_make_attachments_polymorphic.rb
    # @see decidim-participatory-processes/db/migrate/20251203071213_remove_legacy_file_column_from_attachments_table.rb
    remove_column :decidim_attachments, :file, :string if table_exists?(:decidim_attachments) && column_exists?(:decidim_attachments, :file)

    remove_column :decidim_users, :avatar, :string

    remove_column :decidim_private_exports, :file, :string
  end
end
