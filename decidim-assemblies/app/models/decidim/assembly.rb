# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization can be done via an Assembly.
  # It's a unit of action from the Organization point of view that groups
  # several features (proposals, debates...) that can be enabled or disabled.
  class Assembly < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Followable
    include Decidim::HasReference

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :scope,
               foreign_key: "decidim_scope_id",
               class_name: "Decidim::Scope",
               optional: true
    belongs_to :area,
               foreign_key: "decidim_area_id",
               class_name: "Decidim::Area",
               optional: true
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    has_many :features, as: :participatory_space, dependent: :destroy

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::BannerImageUploader

    # Scope to return only the promoted assemblies.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end
  end
end
