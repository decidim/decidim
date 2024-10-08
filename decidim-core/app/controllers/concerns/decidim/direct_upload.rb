# frozen_string_literal: true

module Decidim
  module DirectUpload
    extend ActiveSupport::Concern

    included do
      include Decidim::NeedsOrganization
      skip_before_action :verify_organization

      before_action :check_organization!,
                    :check_authenticated!,
                    :check_user_belongs_to_organization,
                    :validate_direct_upload
    end

    protected

    def validate_direct_upload
      # We skip the validation if we are in system panel. `current_admin` refers to the main system admin user.
      return if current_admin.present?

      head :unprocessable_entity unless [
        maximum_allowed_size.try(:to_i) >= blob_args[:byte_size].try(:to_i),
        content_types.any? { |pattern| pattern.match?(blob_args[:content_type]) },
        content_types.any? { |pattern| pattern.match?(MiniMime.lookup_by_extension(extension)&.content_type) },
        allowed_extensions.any? { |pattern| pattern.match?(extension) }
      ].all?
    rescue NoMethodError
      head :unprocessable_entity
    end

    def extension
      File.extname(blob_args[:filename]).delete(".")
    end

    def maximum_allowed_size
      current_organization.settings.upload_maximum_file_size
    end

    def check_organization!
      head :unauthorized if current_organization.blank? && current_admin.blank?
    end

    def check_authenticated!
      head :unauthorized if current_user.blank? && current_admin.blank?
    end

    def check_user_belongs_to_organization
      return if current_admin.present?

      head :unauthorized unless current_organization == current_user.organization
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
      [
        current_user&.admin?,
        defined?(Decidim::Assemblies::AssembliesWithUserRole) && Decidim::Assemblies::AssembliesWithUserRole.for(current_user).any?,
        defined?(Decidim::Conferences::ConferencesWithUserRole) && Decidim::Conferences::ConferencesWithUserRole.for(current_user).any?,
        defined?(Decidim::ParticipatoryProcessesWithUserRole) && Decidim::ParticipatoryProcessesWithUserRole.for(current_user).any?
      ].any?
    end
  end
end
