# frozen_string_literal: true

namespace :decidim do
  namespace :active_storage_migrations do
    desc "Migrates attachments from Carrierwave to ActiveStorage"
    task migrate_from_carrierwave_to_active_storage: :environment do
      # Setup a new logger, using the timestamp to identify each migration
      logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Time.now.strftime("%Y%m%d%H%M")}_activestorage_migration.log"))

      [
        [ Decidim::Attachment, "file", Decidim::AttachmentUploader, "file" ],
        [ Decidim::User, "avatar", Decidim::AvatarUploader, "avatar" ],
        # Complete the list of classes and old uploaders
      ].each do |(klass, attachment_attribute, carrierwave_uploader, active_storage_column)|
        Decidim::CarrierWaveMigratorService.migrate_attachment!({
          klass: klass, attachment_attribute: attachment_attribute,
          carrierwave_uploader: carrierwave_uploader, active_storage_column: active_storage_column,
          logger: logger
        })
      end
    end

    # TODO:
    #   - implement the checker, probably based on the migrate service
    # desc "Checks attachments migrated from Carrierwave to ActiveStorage"
    # task check_migration_from_carrierwave_to_active_storage: :environment do
    #   [
    #     [ Decidim::Attachment, "file", Decidim::AttachmentUploader, "file" ],
    #     [ Decidim::User, "avatar", Decidim::AvatarUploader, "avatar" ],
    #     # Complete the list of classes and old uploaders
    #   ].each do |(klass, attachment_attribute, carrierwave_uploader, active_storage_column)|
    #     Decidim::CarrierWaveMigratorService.migrate_attachment!({
    #       klass: klass, attachment_attribute: attachment_attribute,
    #       carrierwave_uploader: carrierwave_uploader, active_storage_column: active_storage_column
    #     })
    #   end
    # end

    # TODO: remove old Carrierwave attachments
    # desc "Removes old carrierwave attachments"
    # task remove_carrierwave_attachments: :environment do
    # end
  end
end
