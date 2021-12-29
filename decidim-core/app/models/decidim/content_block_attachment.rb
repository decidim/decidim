# frozen_string_literal: true

module Decidim
  # Attachment can be any type of document or images related to a partcipatory
  # process.
  class ContentBlockAttachment < ApplicationRecord
    include Decidim::HasUploadValidations

    belongs_to :content_block, foreign_key: "decidim_content_block_id", class_name: "Decidim::ContentBlock", inverse_of: :attachments

    has_one_attached :file
    validates_upload :file

    delegate :attached?, to: :file
    delegate :organization, :manifest, to: :content_block

    def uploader
      return if content_block.blank?

      config = manifest.images.find do |image_config|
        image_config[:name].to_s == name.to_s
      end

      return if config.blank?

      config[:uploader].constantize
    end

    def attached_uploader(name)
      return unless name == :file

      uploader.new(self, :file)
    end
  end
end
