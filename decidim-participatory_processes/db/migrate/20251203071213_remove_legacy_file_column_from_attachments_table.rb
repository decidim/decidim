# frozen_string_literal: true

class RemoveLegacyFileColumnFromAttachmentsTable < ActiveRecord::Migration[7.2]
  # To have the migrations consistents between a new and an already existing application
  # We need to remove this column from here too
  #
  # @see decidim-core/db/migrate/20251112132305_remove_legacy_images_from_core_module.rb
  def change
    remove_column :decidim_attachments, :file, :string if table_exists?(:decidim_attachments) && column_exists?(:decidim_attachments, :file)
  end
end
