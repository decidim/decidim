# frozen_string_literal: true

module Decidim
  module DirectUpload
    extend ActiveSupport::Concern

    included do
      include Decidim::NeedsOrganization

      skip_before_action :verify_organization

      before_action :check_organization!,
                    :validate_direct_upload
    end

    protected

    def validate_direct_upload
      # We skip the validation if we are in system panel. `current_admin` refers to the main system admin user.
      return if current_admin.present?

      # The size limit is checked against the byte_size declared by the client. The
      # contents are sent straight to the storage service by the browser and are
      # never compared with the declared value, so only what the client declares is
      # enforced here.
      head :unprocessable_content unless [
        maximum_allowed_size.try(:to_i) >= blob_args[:byte_size].try(:to_i),
        content_types.any? { |pattern| pattern.match?(blob_args[:content_type]) },
        content_types.any? { |pattern| pattern.match?(extension_content_type) },
        allowed_extensions.any? { |pattern| pattern.match?(extension) },
        # The contents of a direct upload are sent straight to the storage
        # service, so the bytes cannot be inspected at this point and the content
        # type declared by the client cannot be verified against them. It is at
        # least required to be consistent with the type derived from the file
        # extension, so that a file cannot be stored with a false declaration;
        # the actual contents are checked by UploaderImageContentValidator when
        # the blob is attached to a record.
        content_type_matches_extension?(blob_args[:content_type], extension_content_type)
      ].all?
    rescue NoMethodError
      head :unprocessable_content
    end

    def extension
      File.extname(blob_args[:filename]).delete(".")
    end

    def extension_content_type
      MiniMime.lookup_by_extension(extension)&.content_type
    end

    # Whether the content type declared by the client is the one derived from the
    # file extension, or one of the aliases accepted for the same format.
    def content_type_matches_extension?(declared, derived)
      return true if derived.nil?

      normalized = Decidim::UploadContentTypes.normalize(declared)
      return true if normalized == derived

      Decidim::UploadContentTypes.accepted_types(derived)&.include?(normalized)
    end

    def maximum_allowed_size
      current_organization.settings.upload_maximum_file_size
    end

    def check_organization!
      head :unauthorized if current_organization.blank? && current_admin.blank?
    end

    def allowed_extensions
      if user_has_elevated_role?
        current_organization.settings.upload_allowed_file_extensions_admin
      else
        current_organization.settings.upload_allowed_file_extensions
      end
    end

    def content_types
      if user_has_elevated_role?
        current_organization.settings.upload_allowed_content_types_admin
      else
        current_organization.settings.upload_allowed_content_types
      end
    end

    private

    def user_has_elevated_role?
      return false if current_user.blank? || current_organization.blank? || current_user.organization != current_organization

      [
        current_user&.admin?,
        defined?(Decidim::Assemblies::AssembliesWithUserRole) && Decidim::Assemblies::AssembliesWithUserRole.for(current_user).any?,
        defined?(Decidim::Conferences::ConferencesWithUserRole) && Decidim::Conferences::ConferencesWithUserRole.for(current_user).any?,
        defined?(Decidim::ParticipatoryProcessesWithUserRole) && Decidim::ParticipatoryProcessesWithUserRole.for(current_user).any?
      ].any?
    end
  end
end
