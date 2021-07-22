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
          attachment_block.last.each do |attachment|
            next unless attachment.attached?

            blobs = attachment.is_a?(ActiveStorage::Attached::One) ? [attachment.blob] : attachment.blobs
            blobs.each do |blob|
              out.put_next_entry("#{folder_name}/#{blob.filename}")
              blob.open do |f|
                out << f.read
              end
            end
          end
        end
      end
    end
  end
end
