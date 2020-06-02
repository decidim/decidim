# frozen_string_literal: true

module Decidim
  # Initiative type.
  class InitiativesType < ApplicationRecord
    include Decidim::HasResourcePermission
    include Decidim::TranslatableResource

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

    validates :signature_type, presence: true
    validates :title, :description, presence: true

    mount_uploader :banner_image, Decidim::BannerImageUploader

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
  end
end
