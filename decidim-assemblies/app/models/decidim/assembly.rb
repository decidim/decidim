# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization can be done via an Assembly.
  # It's a unit of action from the Organization point of view that groups
  # several components (proposals, debates...) that can be enabled or disabled.
  class Assembly < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Followable
    include Decidim::HasReference
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :area,
               foreign_key: "decidim_area_id",
               class_name: "Decidim::Area",
               optional: true
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    has_many :components, as: :participatory_space, dependent: :destroy

    has_many :children, foreign_key: "parent_id", class_name: "Decidim::Assembly", inverse_of: :parent, dependent: :destroy
    belongs_to :parent, foreign_key: "parent_id", class_name: "Decidim::Assembly", inverse_of: :children, optional: true, counter_cache: :children_count

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

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssemblyPresenter
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end

    def ancestors
      @ancestors ||= begin
        current_assembly = self
        [].tap do |ancestors|
          until current_assembly.parent.nil?
            current_assembly = current_assembly.parent
            ancestors.unshift current_assembly
          end
        end
      end
    end
  end
end
