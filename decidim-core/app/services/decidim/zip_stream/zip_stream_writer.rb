# frozen_string_literal: true

module Decidim
  module ZipStream
    module Writer
      def add_user_data_to_zip_stream(out, user_data)
        user_data.each do |element|
          filename_file = element.last.filename(element.first.parameterize)

          out.put_next_entry(filename_file)
          if element.last.read.presence
            out.write element.last.read
          else
            out.write "No data"
          end
        end
      end

      def add_attachments_to_zip_stream(out, export_attachments)
        export_attachments.each do |attachment_block|
          next if attachment_block.last.nil?

          folder_name = attachment_block.first.parameterize
          attachment_block.last.each do |attachment_uploader|
            next if attachment_uploader.file.nil?

            case attachment_uploader.provider
            when "file" # file system
              next unless File.exist?(attachment_uploader.file.file)
            when "aws"
              cache_attachment_from_aws(attachment_uploader)
            else
              Rails.logger.info "Carrierwave fog_provider not supported by DataPortabilityExporter for attachment: #{attachment_uploader}"
              next
            end

            attachment_local_path = attachment_uploader.file.file
            out.put_next_entry("#{folder_name}/#{attachment_uploader.file.filename}")
            File.open(attachment_local_path) do |f|
              out << f.read
            end
            CarrierWave.clean_cached_files!
          end
        end
      end

      # Retrieves the file from AWS and stores it into a temporal cache.
      # Once the file is cached, the uploader returns a local `CarrierWave::SanitizedFile`
      # instead of a fog file that acts as a proxy to the remote file.
      def cache_attachment_from_aws(uploader)
        uploader.cache_stored_file!
        uploader.retrieve_from_cache!(uploader.cache_name)
      end
    end
  end
end
