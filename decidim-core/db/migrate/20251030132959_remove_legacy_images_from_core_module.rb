# frozen_string_literal: true
 
class RemoveLegacyImagesFromCoreModule< ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_organizations, :logo, :string
    remove_column :decidim_organizations, :official_img_footer, :string
    remove_column :decidim_organizations, :favicon, :string

    remove_column :oauth_applications, :organization_logo, :string

    remove_column :decidim_authorizations, :verification_attachment, :string

    remove_column :decidim_attachments, :file, :string

    remove_column :decidim_users, :avatar, :string

    remove_column :decidim_private_exports, :file, :string
  end
end
