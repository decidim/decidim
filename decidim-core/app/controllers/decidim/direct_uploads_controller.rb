# frozen_string_literal: true

module Decidim
  class DirectUploadsController < ActiveStorage::DirectUploadsController
    include Decidim::NeedsOrganization
    skip_before_action :verify_organization

    before_action :check_organization!
    before_action :check_authenticated!
    before_action :validate_direct_upload

    protected

    def validate_direct_upload
      maximum_allowed_size = current_organization.settings.upload_maximum_file_size

      extension = File.extname(blob_args[:filename]).delete(".")

      head :unprocessable_entity unless maximum_allowed_size.try(:to_i) >= blob_args[:byte_size]
      head :unprocessable_entity unless content_types.any? { |pattern| pattern.match?(blob_args[:content_type]) }
      head :unprocessable_entity unless content_types.any? { |pattern| pattern.match?(MiniMime.lookup_by_extension(extension).content_type) }
      head :unprocessable_entity unless allowed_extensions.any? { |pattern| pattern.match?(extension) }
    rescue NoMethodError
      head :unprocessable_entity
    end

    def check_organization!
      head :unauthorized if current_organization.blank?
    end

    def check_authenticated!
      head :unauthorized if current_user.blank?
    end

    def allowed_extensions
      if URI.parse(request.referer).path.starts_with?("/admin")
        current_organization.settings.upload_allowed_file_extensions_admin
      else
        current_organization.settings.upload_allowed_file_extensions
      end
    end

    def content_types
      if URI.parse(request.referer).path.starts_with?("/admin")
        current_organization.settings.upload_allowed_content_types_admin
      else
        current_organization.settings.upload_allowed_content_types
      end
    end
  end
end
