# frozen_string_literal: true

require "English"

module Decidim
  module CarrierWaveMigratorService
    MIGRATION_ATTRIBUTES = {
      "Decidim::Organization" => lambda do
        [
          [Decidim::Attachment, "file", Decidim::Cw::AttachmentUploader, "file"],
          [Decidim::User, "avatar", Decidim::Cw::AvatarUploader, "avatar"],
          [Decidim::UserGroup, "avatar", Decidim::Cw::AvatarUploader, "avatar"],
          [Decidim::OAuthApplication, "organization_logo", Decidim::Cw::OAuthApplicationLogoUploader, "organization_logo"],
          [Decidim::Authorization, "verification_attachment", Decidim::Cw::Verifications::AttachmentUploader, "verification_attachment"],
          [Decidim::Organization, "official_img_header", Decidim::Cw::OfficialImageHeaderUploader, "official_img_header"],
          [Decidim::Organization, "official_img_footer", Decidim::Cw::OfficialImageFooterUploader, "official_img_footer"],
          [Decidim::Organization, "logo", Decidim::Cw::OrganizationLogoUploader, "logo"],
          [Decidim::Organization, "favicon", Decidim::Cw::OrganizationFaviconUploader, "favicon"],
          [Decidim::Organization, "highlighted_content_banner_image", Decidim::Cw::ImageUploader, "highlighted_content_banner_image"]
        ]
      end,
      "Decidim::Conference" => lambda do
        [
          [Decidim::Conference, "hero_image", Decidim::Cw::HeroImageUploader, "hero_image"],
          [Decidim::Conference, "banner_image", Decidim::Cw::HomepageImageUploader, "banner_image"],
          [Decidim::Conference, "main_logo", Decidim::Cw::Conferences::DiplomaUploader, "main_logo"],
          [Decidim::Conference, "signature", Decidim::Cw::Conferences::DiplomaUploader, "signature"],
          [Decidim::ConferenceSpeaker, "avatar", Decidim::Cw::AvatarUploader, "avatar"],
          [Decidim::Conferences::Partner, "logo", Decidim::Cw::Conferences::PartnerLogoUploader, "logo"]
        ]
      end,
      "Decidim::Consultation" => lambda do
        [
          [Decidim::Consultations::Question, "hero_image", Decidim::Cw::HeroImageUploader, "hero_image"],
          [Decidim::Consultations::Question, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"],
          [Decidim::Consultation, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"],
          [Decidim::Consultation, "introductory_image", Decidim::Cw::BannerImageUploader, "introductory_image"]
        ]
      end,
      "Decidim::Votings::Voting" => lambda do
        [
          [Decidim::Votings::Voting, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"],
          [Decidim::Votings::Voting, "introductory_image", Decidim::Cw::BannerImageUploader, "introductory_image"]
        ]
      end,
      "Decidim::ParticipatoryProcess" => lambda do
        [
          [Decidim::ParticipatoryProcess, "hero_image", Decidim::Cw::HeroImageUploader, "hero_image"],
          [Decidim::ParticipatoryProcess, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"],
          [Decidim::ParticipatoryProcessGroup, "hero_image", Decidim::Cw::HeroImageUploader, "hero_image"]
        ]
      end,
      "Decidim::Assembly" => lambda do
        [
          [Decidim::Assembly, "hero_image", Decidim::Cw::HeroImageUploader, "hero_image"],
          [Decidim::Assembly, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"]
        ]
      end,
      "Decidim::Initiative" => lambda do
        [
          [Decidim::InitiativesType, "banner_image", Decidim::Cw::BannerImageUploader, "banner_image"]
        ]
      end
    }.sum do |main_model, attributes|
      main_model.constantize.is_a?(Class) ? attributes.call : []
    rescue NameError
      []
    end.freeze

    def self.check_content_blocks_attachments(logger:)
      Decidim::ContentBlock.find_each do |block|
        next if block.images.blank?

        block.manifest.images.each do |image_config|
          attachment = cw_images_container(block).send(image_config[:name])
          destination = block.images_container.send(image_config[:name])

          next if attachment.file.blank?

          if destination.attached?
            attachment.cache_stored_file!
            file = cw_file(attachment)

            cw_checksum = downloaded_file_checksum(file)
            as_checksum = destination.blob.checksum

            logger.info "#{cw_checksum == as_checksum ? "[OK] Checksum identical:" : "[KO] Checksum different:"}" \
                        " Migrated Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                        " from CW attribute #{image_config[:name]} to AS" \
                        " in Decidim::ContentBlockAttachment##{destination.record.id} file attribute"
          else
            logger.info "[SKIP] Pending migration of Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                        " from CW attribute #{image_config[:name]} to AS" \
          end
        rescue StandardError
          logger.info "[ERROR] Exception checking Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                      " from CW attribute #{image_config[:name]} to AS file attribute in a Decidim::ContentBlockAttachment instance #{$ERROR_INFO}"
        end
      end
    end

    def self.migrate_content_blocks_attachments!(logger:, routes_mappings: [])
      Decidim::ContentBlock.find_each do |block|
        next if block.images.blank?

        block.manifest.images.each do |image_config|
          destination = block.images_container.send(image_config[:name])

          if destination.attached?
            logger.info "[SKIP] Migrated Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                        " from CW attribute #{image_config[:name]} to AS" \
                        " in Decidim::ContentBlockAttachment##{destination.record.id} file attribute"
            next
          end

          attachment = cw_images_container(block).send(image_config[:name])
          next if attachment.file.blank?

          origin_path = attachment.url
          attachment.cache_stored_file!
          content_type = attachment.content_type
          filename = block.images[image_config[:name].to_s]
          file = cw_file(attachment)
          destination.attach(
            io: file,
            content_type:,
            filename:
          )
          destination.record.save if destination.record.new_record?

          cw_checksum = downloaded_file_checksum(file)
          as_checksum = destination.blob.checksum

          logger.info "[OK] Migrated - #{cw_checksum == as_checksum ? "[OK] Checksum identical:" : "[KO] Checksum different:"}" \
                      " Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                      " from CW attribute #{image_config[:name]} to AS" \
                      " in Decidim::ContentBlockAttachment##{destination.record.id} file attribute" \

          routes_mappings << { instance: "Decidim::ContentBlock##{block.id}",
                               attachment_origin_attribute: image_config[:name],
                               origin_path:,
                               destination_path: Rails.application.routes.url_helpers.rails_blob_url(destination.blob, only_path: true) }
        rescue StandardError
          logger.info "[ERROR] Exception migrating Decidim::ContentBlock##{block.id} attachment #{image_config[:name]}" \
                      " from CW attribute #{image_config[:name]} to AS file attribute in a Decidim::ContentBlockAttachment instance #{$ERROR_INFO}"
        end
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def self.migrate_attachment!(klass:, cw_attribute:, cw_uploader:, logger:, as_attribute: cw_attribute, routes_mappings: [])
      old_class = cw_attachments_class(klass, cw_attribute, cw_uploader)

      old_class.items.each do |item|
        next if item.send(cw_attribute).blank?

        copy = klass.find(item.id)
        # Skip record if already been processed
        if copy.send(as_attribute).attached?
          logger.info "[SKIP] Migrated #{klass}##{item.id} from CW attribute #{cw_attribute} to AS #{as_attribute} attribute"
          next
        end

        attachment = item.send(cw_attribute)
        origin_path = attachment.url
        attachment.cache_stored_file!
        content_type = attachment.content_type
        filename = item.attributes[cw_attribute.to_s]
        file = cw_file(attachment)
        copy.send(as_attribute).attach(
          io: file,
          content_type:,
          filename:
        )

        cw_checksum = downloaded_file_checksum(file)
        as_checksum = copy.send(as_attribute).blob.checksum

        logger.info "[OK] Migrated - #{cw_checksum == as_checksum ? "[OK] Checksum identical:" : "[KO] Checksum different:"}" \
                    " #{klass}##{item.id} from CW attribute #{cw_attribute} to AS #{as_attribute} attribute"

        routes_mappings << {
          instance: "#{klass}##{item.id}",
          attachment_origin_attribute: cw_attribute.to_s,
          origin_path:,
          destination_path: Rails.application.routes.url_helpers.rails_blob_url(copy.send(as_attribute).blob, only_path: true)
        }
      rescue StandardError
        logger.info "[ERROR] Exception migrating #{klass}##{item.id} from CW attribute #{cw_attribute} to AS #{as_attribute} attribute #{$ERROR_INFO}"
      end
    end
    # rubocop:enable Metrics/ParameterLists

    def self.check_migration(klass:, cw_attribute:, cw_uploader:, logger:, as_attribute: cw_attribute)
      old_class = cw_attachments_class(klass, cw_attribute, cw_uploader)

      old_class.items.each do |item|
        next if item.send(cw_attribute).blank?

        copy = klass.find(item.id)

        if copy.send(as_attribute).attached?
          attachment = item.send(cw_attribute)
          attachment.cache_stored_file!
          file = cw_file(attachment)

          cw_checksum = downloaded_file_checksum(file)
          as_checksum = copy.send(as_attribute).blob.checksum

          logger.info "#{cw_checksum == as_checksum ? "[OK] Checksum identical:" : "[KO] Checksum different:"}" \
                      " Migrated #{klass}##{item.id} from CW attribute #{cw_attribute}" \
                      " to AS #{as_attribute} attribute"
        else
          logger.info "[SKIP] Pending migration of #{klass}##{item.id} from CW attribute #{cw_attribute} to AS #{as_attribute} attribute"
        end
      rescue StandardError
        logger.info "[ERROR] Exception checking #{klass}##{item.id} from CW attribute #{cw_attribute} to AS #{as_attribute} attribute #{$ERROR_INFO}"
      end
    end

    def self.cw_attachments_class(klass, cw_attribute, cw_uploader)
      has_sti = klass.column_names.include?(klass.inheritance_column)

      attachments_class = Class.new(ApplicationRecord) do
        cattr_accessor :klass

        self.table_name = klass.table_name

        if has_sti
          self.inheritance_column = nil
          scope :items, -> { where(type: klass.name) }
        else
          scope :items, -> { all }
        end
        mount_uploader cw_attribute, cw_uploader

        def self.to_s
          klass.to_s
        end
      end

      attachments_class.klass = klass
      attachments_class
    end

    def self.cw_images_container(block)
      manifest = block.manifest
      images_container_class = Class.new do
        extend ::CarrierWave::Mount
        include ActiveModel::Validations

        cattr_accessor :manifest, :manifest_scope
        attr_reader :content_block

        delegate :id, :organization, to: :content_block

        def self.to_s
          "decidim/#{manifest.name.to_s.underscore}_#{manifest_scope.to_s.underscore}_content_block"
        end

        def initialize(content_block)
          @content_block = content_block
        end

        manifest.images.each do |image_config|
          mount_uploader image_config[:name], image_config[:uploader].gsub("Decidim::", "Decidim::Cw::").constantize
        end

        def read_uploader(column)
          content_block.images[column.to_s]
        end
      end

      images_container_class.manifest = block.manifest
      images_container_class.manifest_scope = block.scope_name
      images_container_class.new(block)
    end

    def self.downloaded_file_checksum(file)
      if file.is_a?(StringIO)
        Digest::MD5.base64digest(file.read)
      else
        Digest::MD5.file(file).base64digest
      end
    end

    def self.cw_file(attachment)
      if attachment.file.is_a?(CarrierWave::Storage::Fog::File)
        URI.parse(attachment.url).open
      else
        File.open(attachment.file.file)
      end
    end
  end
end
