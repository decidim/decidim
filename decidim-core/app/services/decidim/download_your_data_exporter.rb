# frozen_string_literal: true

module Decidim
  # Public: Generates a zip archive with data files ready to be persisted
  # somewhere so users can download their data.
  #
  class DownloadYourDataExporter
    DEFAULT_EXPORT_FORMAT = "CSV"
    ZIP_FILE_NAME = "download-your-data.zip"

    include Decidim::TranslatableAttributes

    # Public: Initializes the class.
    #
    # user          - The user to export the data from.
    # name          - The name of the export in private area
    # export_format - The format of the data files inside the zip file. (CSV by default)
    def initialize(user, name, export_format = DEFAULT_EXPORT_FORMAT)
      @user = user
      @export_format = export_format
      @name = name
    end

    # i18n-tasks-use t("decidim.download_your_data.show.download_your_data")
    def export
      user_export = user.private_exports.build
      user_export.export_type = name
      user_export.file.attach(io: data, filename: "#{name}.zip", content_type: "application/zip")
      user_export.expires_at = Decidim.download_your_data_expiry_time.from_now
      user_export.metadata = {}
      user_export.save!
      user_export
    end

    private

    attr_reader :user, :export_format, :name

    def data
      user_data, user_attachments = data_and_attachments_for_user
      buffer = Zip::OutputStream.write_buffer do |out|
        save_user_data(out, user_data)
        save_user_attachments(out, user_attachments)
        save_readme(out)
      end

      buffer.rewind
      buffer
    end

    def data_and_attachments_for_user
      export_data = []
      export_attachments = []

      download_your_data_entities.each do |object|
        klass = Object.const_get(object)
        exporter = Exporters.find_exporter(export_format).new(klass.user_collection(user), klass.export_serializer)
        export_data << [klass.model_name.name.parameterize.pluralize, exporter.export]
        attachments = klass.download_your_data_images(user)
        export_attachments << [klass.model_name.name.parameterize.pluralize, attachments.flatten] unless attachments.nil?
      end

      [export_data, export_attachments]
    end

    def download_your_data_entities
      @download_your_data_entities ||= DownloadYourDataSerializers.data_entities
    end

    def save_user_data(output, user_data)
      user_data.each do |entity, exporter_data|
        next if exporter_data.read == "\n"

        output.put_next_entry("#{entity}-#{exporter_data.filename}")
        output.write exporter_data.read
      end
    end

    def save_user_attachments(output, user_attachments)
      user_attachments.each do |entity, attachment_block|
        attachment_block.each do |attachment|
          next unless attachment.attached?

          blobs = attachment.is_a?(ActiveStorage::Attached::One) ? [attachment.blob] : attachment.blobs
          blobs.each do |blob|
            blob.open do |blob_file|
              output.put_next_entry("#{entity.parameterize}/#{blob.filename}")
              output.write blob_file.read.force_encoding("UTF-8")
            end
          end
        end
      end
    end

    def save_readme(output)
      output.put_next_entry("README.md")
      output.write readme
    end

    def readme
      readme_file = "# #{I18n.t("decidim.download_your_data.help.core.title", organization: translated_attribute(user.organization.name))}\n\n"
      readme_file << "#{I18n.t("decidim.download_your_data.help.core.description", user_name: "#{user.name} (#{user.nickname})")}\n\n"
      help_definition = DownloadYourDataSerializers.help_definitions_for(user)

      help_definition.each do |entity, headers|
        next if headers.empty?

        readme_file << "\n\n## #{entity}\n\n"

        headers.each do |header, help_value|
          readme_file << "* #{header}: #{help_value}\n"
        end
      end

      readme_file
    end
  end
end
