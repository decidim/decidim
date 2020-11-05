# frozen_string_literal: true

class AddFileUploadSettingsToDecidimOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :file_upload_settings, :jsonb

    reversible do |dir|
      dir.up do
        Decidim.configure do |config|
          # Even when these configurations have been deleted, they are available
          # in the config object if they are defined by the initializer.
          attachment_size = config.fetch(:maximum_attachment_size, 10.megabytes)
          avatar_size = config.fetch(:maximum_avatar_size, 5.megabytes)

          # Update all organizations with the default file upload settings.
          Decidim::Organization.all.each do |organization|
            organization.update(
              file_upload_settings: default_settings.merge(
                "maximum_file_size" => {
                  "default" => attachment_size / 1.megabyte,
                  "avatar" => avatar_size / 1.megabyte
                }
              )
            )
          end
        end
      end
    end
  end

  private

  def default_settings
    Decidim::OrganizationSettings.default(:upload)
  end
end
