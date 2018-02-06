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

    has_many :assembly_private_users, class_name: "Decidim::AssemblyPrivateUser", foreign_key: "decidim_assembly_id", dependent: :destroy
    has_many :users, through: :assembly_private_users, class_name: "Decidim::User", foreign_key: "decidim_user_id"

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::BannerImageUploader

    scope :private_spaces_user, lambda { |user|
      joins("LEFT JOIN decidim_assembly_private_users ON
             decidim_assembly_private_users.decidim_assembly_id = decidim_assemblies.id")
        .where("(private_space = true and decidim_assembly_private_users.decidim_user_id
             = #{user} ) or private_space = false")
    }
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

    def private_space?
      private_space
    end

    def self.private_space
      where(private_space: true)
    end

    def self.public_assembly
      where(private_space: false)
    end
  end
end
