# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization can be done via an Assembly.
  # It's a unit of action from the Organization point of view that groups
  # several components (proposals, debates...) that can be enabled or disabled.
  #
  # An assembly can have children. This is implemented using a PostgreSQL extension: LTREE
  # The LTREE extension allows us to save, query on and manipulate trees (hierarchical data
  # structures). It uses the path enumeration algorithm, which calls for each node in the
  # tree to record the path from the root you would have to follow to reach that node.
  #
  # We use the `parents_path` column to save the path and query the tree. Example:
  #
  # A (root assembly) parent = null, parents_path = A
  # B (root assembly) parent = null, parents_path = B
  # |- C (child assembly of B, descendant of B) parent = B, parents_path = B.C
  #    |- D (child assembly of C, descendant of B,C) parent = C, parents_path = B.C.D
  #    |- E (child assembly of C, descendant of B,C) parent = C, parents_path = B.C.E
  #       |- F (child assembly of E, descendant of B,C,E) parent = E, parents_path = B.C.E.F
  #
  class Assembly < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::ScopableParticipatorySpace
    include Decidim::Followable
    include Decidim::HasReference
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::ParticipatorySpaceResourceable
    include Decidim::HasPrivateUsers
    include Decidim::Searchable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource
    include Decidim::HasArea
    include Decidim::FilterableResource

    SOCIAL_HANDLERS = [:twitter, :facebook, :instagram, :youtube, :github].freeze
    CREATED_BY = %w(city_council public others).freeze

    translatable_fields :title, :subtitle, :short_description, :description, :developer_group, :meta_scope, :local_area,
                        :target, :participatory_scope, :participatory_structure, :purpose_of_action, :composition, :created_by_other,
                        :closing_date_reason, :internal_organisation, :special_features, :announcement

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :area,
               foreign_key: "decidim_area_id",
               class_name: "Decidim::Area",
               optional: true
    belongs_to :assembly_type,
               foreign_key: "decidim_assemblies_type_id",
               class_name: "Decidim::AssembliesType",
               optional: true
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    has_many :members,
             foreign_key: "decidim_assembly_id",
             class_name: "Decidim::AssemblyMember",
             dependent: :destroy

    has_many :components, as: :participatory_space, dependent: :destroy

    has_many :children, foreign_key: "parent_id", class_name: "Decidim::Assembly", inverse_of: :parent, dependent: :destroy
    belongs_to :parent, class_name: "Decidim::Assembly", inverse_of: :children, optional: true, counter_cache: :children_count

    has_one_attached :hero_image
    validates_upload :hero_image, uploader: Decidim::HeroImageUploader

    has_one_attached :banner_image
    validates_upload :banner_image, uploader: Decidim::BannerImageUploader

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

    after_create :set_parents_path
    after_update :set_parents_path, :update_children_paths, if: :saved_change_to_parent_id?

    searchable_fields({
                        scope_id: :decidim_scope_id,
                        participatory_space: :itself,
                        A: :title,
                        B: :subtitle,
                        C: :short_description,
                        D: :description,
                        datetime: :published_at
                      },
                      index_on_create: ->(_assembly) { false },
                      index_on_update: ->(assembly) { assembly.visible? })

    # Overwriting existing method Decidim::HasPrivateUsers.public_spaces
    def self.public_spaces
      where(private_space: false).or(where(private_space: true).where(is_transparent: true)).published
    end

    # Scope to return only the promoted assemblies.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    # Return parent assemblies.
    def self.parent_assemblies
      where(parent_id: nil)
    end

    # Return child assemblies.
    def self.child_assemblies
      where.not(parent_id: nil)
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
      self.class.where("#{self.class.table_name}.parents_path @> ?", parents_path).order(Arel.sql("string_to_array(#{self.class.table_name}.parents_path::text, '.')"))
    end

    def ancestors
      self_and_ancestors.where.not(id:)
    end

    def translated_title
      Decidim::AssemblyPresenter.new(self).translated_title
    end

    def closed?
      return false if closing_date.blank?

      closing_date < Date.current
    end

    def user_roles(role_name = nil)
      roles = Decidim::AssemblyUserRole.where(assembly: self_and_ancestors)
      return roles if role_name.blank?

      roles.where(role: role_name)
    end

    def attachment_context
      :admin
    end

    def self.ransackable_scopes(_auth_object = nil)
      [:with_area, :with_scope]
    end

    private

    # When an assembly changes their parent, we need to update the parents_path attribute
    # E.g. If we have the following tree:
    #
    # A (root assembly) parent = null, parents_path = A
    # B (root assembly) parent = null, parents_path = B
    # |- C (child assembly of B, descendant of B) parent = B, parents_path = B.C
    #    |- D (child assembly of C, descendant of B,C) parent = C, parents_path = B.C.D
    #
    # And we change the parent of C to A, this function updates their parents_path attribute:
    #
    # |- C (child assembly of *A*, descendant of *A*) parent = *A*, parents_path = *A*.C
    #
    # Note: updating parents_path in their descendants is done in the `update_children_paths` function.
    #
    # rubocop:disable Rails/SkipsModelValidations
    def set_parents_path
      update_column(:parents_path, [parent&.parents_path, id].select(&:present?).join("."))
    end
    # rubocop:enable Rails/SkipsModelValidations

    # When an assembly changes their parent, we need to update the parents_path attribute on their descendants
    # E.g. If we have the following tree:
    #
    # A (root assembly) parent = null, parents_path = A
    # B (root assembly) parent = null, parents_path = B
    # |- C (child assembly of B, descendant of B) parent = B, parents_path = B.C
    #    |- D (child assembly of C, descendant of B,C) parent = C, parents_path = B.C.D
    #    |- E (child assembly of C, descendant of B,C) parent = C, parents_path = B.C.E
    #       |- F (child assembly of E, descendant of B,C,E) parent = E, parents_path = B.C.E.F
    #
    # And we change the parent of C to A, this function updates the parents_path attribute in their
    # descendants assemblies (D, E and F):
    #
    #    |- D (child assembly of C, descendant of *A*,C) parent = C, parents_path = *A*.C.D
    #    |- E (child assembly of C, descendant of *A*,C) parent = C, parents_path = *A*.C.E
    #       |- F (child assembly of E, descendant of *A*,C,E) parent = E, parents_path = *A*.C.E.F
    #
    # Note: updating parents_path of C (the assembly in which we have changed the parent) is done in the `set_parents_path` function.
    #
    # rubocop:disable Rails/SkipsModelValidations
    def update_children_paths
      self.class.where(
        ["#{self.class.table_name}.parents_path <@ :old_path AND #{self.class.table_name}.id != :id", { old_path: parents_path_before_last_save, id: }]
      ).update_all(
        ["parents_path = :new_path || subpath(parents_path, nlevel(:old_path))", { new_path: parents_path, old_path: parents_path_before_last_save }]
      )
    end
    # rubocop:enable Rails/SkipsModelValidations

    # Allow ransacker to search for a key in a hstore column (`title`.`en`)
    ransacker_i18n :title

    ransack_alias :type_id, :decidim_assemblies_type_id
  end
end
