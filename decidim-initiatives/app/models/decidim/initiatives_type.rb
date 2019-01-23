# frozen_string_literal: true

module Decidim
  # Initiative type.
  class InitiativesType < ApplicationRecord
    include Decidim::HasResourcePermission

    validates :title, :description, presence: true
    validates :online_signature_enabled, inclusion: { in: [true, false] }

    mount_uploader :banner_image, Decidim::BannerImageUploader

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :scopes,
             foreign_key: "decidim_initiatives_types_id",
             class_name: "Decidim::InitiativesTypeScope",
             dependent: :destroy,
             inverse_of: :type

    def allowed_signature_types_for_initiatives
      signature_types = []

      signature_types << "online" if Decidim::Initiatives.online_voting_allowed && online_signature_enabled
      signature_types << "offline" if Decidim::Initiatives.face_to_face_voting_allowed
      signature_types << "any" if signature_types.size == (Initiative.signature_types.size - 1)

      signature_types
    end

    def initiatives
      initiatives_ids = scopes.map { |scope| scope.initiatives.pluck(:id) }.flatten
      Initiative.where(id: initiatives_ids)
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
