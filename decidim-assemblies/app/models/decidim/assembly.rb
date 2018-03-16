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

    after_create :set_parents_path
    after_update :set_parents_path, :update_children_paths, if: :saved_change_to_parent_id?

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

    def self_and_ancestors
      self.class.where("#{self.class.table_name}.parents_path @> ?", parents_path)
    end

    def ancestors
      self_and_ancestors.where.not(id: id)
    end

    private

    # rubocop:disable Rails/SkipsModelValidations
    def set_parents_path
      update_column(:parents_path, [parent&.parents_path, id].select(&:present?).join("."))
    end

    def update_children_paths
      self.class.where(
        ["#{self.class.table_name}.parents_path <@ :old_path AND #{self.class.table_name}.id != :id", old_path: parents_path_before_last_save, id: id]
      ).update_all(
        ["parents_path = :new_path || subpath(parents_path, nlevel(:old_path))", new_path: parents_path, old_path: parents_path_before_last_save]
      )
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
