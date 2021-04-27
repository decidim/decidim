# frozen_string_literal: true

namespace :decidim do
  namespace :active_storage_migrations do
    desc "Migrates attachments from Carrierwave to ActiveStorage"
    task migrate_from_carrierwave_to_active_storage: :environment do
      # Setup a new logger, using the timestamp to identify each migration
      logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Time.current.strftime("%Y%m%d%H%M")}_activestorage_migration.log"))
      routes_mappings = []

      Decidim::CarrierWaveMigratorService::MIGRATION_ATTRIBUTES.each do |(klass, cw_attribute, cw_uploader, as_attribute)|
        Decidim::CarrierWaveMigratorService.migrate_attachment!({
                                                                  klass: klass, cw_attribute: cw_attribute,
                                                                  cw_uploader: cw_uploader, as_attribute: as_attribute,
                                                                  logger: logger,
                                                                  routes_mappings: routes_mappings
                                                                })
      end
      Decidim::CarrierWaveMigratorService.migrate_content_blocks_attachments!(logger: logger, routes_mappings: routes_mappings)

      path = Rails.root.join("tmp/attachment_mappings.csv")
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.open(path, "wb") do |file|
        file.write(Decidim::Exporters::CSV.new(routes_mappings).export.read)
      end
    end

    desc "Checks attachments migrated from Carrierwave to ActiveStorage"
    task check_migration_from_carrierwave_to_active_storage: :environment do
      # Setup a new logger, using the timestamp to identify each migration
      logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Time.current.strftime("%Y%m%d%H%M")}_activestorage_migration_check.log"))
      Decidim::CarrierWaveMigratorService::MIGRATION_ATTRIBUTES.each do |(klass, cw_attribute, cw_uploader, as_attribute)|
        Decidim::CarrierWaveMigratorService.check_migration({
                                                              klass: klass, cw_attribute: cw_attribute,
                                                              cw_uploader: cw_uploader, as_attribute: as_attribute,
                                                              logger: logger
                                                            })
      end
      Decidim::CarrierWaveMigratorService.check_content_blocks_attachments(logger: logger)
    end
  end
end
