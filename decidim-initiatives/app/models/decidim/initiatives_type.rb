# frozen_string_literal: true

module Decidim
  # Initiative type.
  class InitiativesType < ApplicationRecord
    include Decidim::HasResourcePermission
    include Decidim::TranslatableResource
    include Decidim::HasUploadValidations
    include Decidim::Traceable

    translatable_fields :title, :description, :extra_fields_legal_information

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :scopes,
             foreign_key: "decidim_initiatives_types_id",
             class_name: "Decidim::InitiativesTypeScope",
             dependent: :destroy,
             inverse_of: :type

    has_many :initiatives,
             through: :scopes,
             class_name: "Decidim::Initiative"

    enum signature_type: [:online, :offline, :any], _suffix: true

    validates :title, :description, :signature_type, presence: true

    has_one_attached :banner_image
    validates_upload :banner_image, uploader: Decidim::BannerImageUploader

    def allowed_signature_types_for_initiatives
      return %w(online offline any) if any_signature_type?

      Array(signature_type.to_s)
    end

    def allow_resource_permissions?
      true
    end

    def mounted_admin_engine
      "decidim_admin_initiatives"
    end

    def mounted_params
      { host: organization.host }
    end

    def self.log_presenter_class_for(_log)
      Decidim::Initiatives::AdminLog::InitiativesTypePresenter
    end

    def signature_workflow_manifest
      Decidim::Initiatives::Signatures.find_workflow_manifest(document_number_authorization_handler)
    end
  end
end
