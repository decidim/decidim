# frozen_string_literal: true

module Decidim
  # Initiative type.
  class InitiativesType < ApplicationRecord
    validates :title, :description, presence: true

    mount_uploader :banner_image, Decidim::BannerImageUploader

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :scopes,
             foreign_key: "decidim_initiatives_types_id",
             class_name: "Decidim::InitiativesTypeScope",
             dependent: :destroy,
             inverse_of: :type
  end
end
