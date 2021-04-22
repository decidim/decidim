# frozen_string_literal: true

module Decidim
  module CarrierWaveMigratorService
    # examples of use:
    # Decidim::CarrierWaveMigratorService.migrate_attachment!(klass: Decidim::Attachment, attachment_attribute: "file", carrierwave_uploader: Decidim::AttachmentUploader, active_storage_column: "file")
    # Decidim::CarrierWaveMigratorService.migrate_attachment!(klass: Decidim::User, attachment_attribute: "avatar", carrierwave_uploader: Decidim::AvatarUploader, active_storage_column: "avatar")
    def self.migrate_attachment!(klass:, attachment_attribute:, carrierwave_uploader:, active_storage_column: attachment_attribute, logger:)
      namespace = klass.name.deconstantize
      klass_name = klass.name.demodulize
      old_class_name = [namespace, "Old#{klass_name}"].reject(&:blank?).join("::")
      new_class_name = [namespace, "New#{klass_name}"].reject(&:blank?).join("::")
      has_sti = klass.column_names.include?(klass.inheritance_column)

      sti_reset = if has_sti
                    <<~DOC
                      self.inheritance_column = nil
                      scope :items, -> { where(type: "#{klass.name}") }
                    DOC
                  else
                    "scope :items, -> { all }"
                  end

      eval <<~DOC
        class #{new_class_name} < ActiveRecord::Base
          self.table_name = #{klass.name}.table_name
          #{sti_reset}
          has_one_attached :#{active_storage_column}
        end

        class #{old_class_name} < ActiveRecord::Base
          self.table_name = #{klass.name}.table_name
          #{sti_reset}
          mount_uploader :#{attachment_attribute}, #{carrierwave_uploader.name}

          def self.to_s
          #{klass}.to_s
          end
        end
      DOC

      new_class = new_class_name.constantize
      old_class = old_class_name.constantize

      old_class.items.each do |item|
        begin
          next if item.send(attachment_attribute).blank?
          copy = new_class.find(item.id)
          # Skip record if already been processed
          if copy.send(active_storage_column).attached?
            logger.info "[SKIP] Migrated #{klass}##{item.id} from CW attribute #{attachment_attribute} to AS #{active_storage_column} attribute"
            next
          end

          attachment = item.send(attachment_attribute)
          attachment.cache_stored_file!
          content_type = attachment.content_type
          filename = item.attributes[attachment_attribute.to_s]
          copy.send(active_storage_column).attach(io: File.open(attachment.file.file), content_type: content_type, filename: filename)

          logger.info "[OK] Migrated #{klass}##{item.id} from CW attribute #{attachment_attribute} to AS #{active_storage_column} attribute"
        rescue
          logger.info "[ERROR] Exception migrating #{klass}##{item.id} from CW attribute #{attachment_attribute} to AS #{active_storage_column} attribute #{$!}"
        end
      end

      ActiveStorage::Attachment.where(record_type: new_class_name).update_all(record_type: klass.to_s)
    end
  end
end
