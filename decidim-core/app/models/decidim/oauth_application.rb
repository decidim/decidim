# frozen_string_literal: true

module Decidim
  class OAuthApplication < ::Doorkeeper::Application
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::HasUploadValidations

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization", inverse_of: :oauth_applications

    has_one_attached :organization_logo

    # validates_upload cannot be used here because the file is not necessarily
    # attached to any organization yet when creating a new OAuth application.
    # The organization becomes mapped after the OAuth application is created
    # but the logo needs to be uploaded in the front-end already before that.
    validates(
      :organization_logo,
      file_size: { less_than_or_equal_to: ->(record) { record.maximum_upload_size } },
      uploader_content_type: true,
      uploader_image_dimensions: true
    )
    attached_config[:organization_logo] = OpenStruct.new(uploader: OAuthApplicationLogoUploader)

    def owner
      organization
    end

    def type
      "Decidim::OAuthApplication"
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::OAuthApplicationPresenter
    end
  end
end
