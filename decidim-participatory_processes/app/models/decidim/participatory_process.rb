# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization is done via a
  # ParticipatoryProcess. It's a unit of action from the Organization point of
  # view that groups several components (proposals, debates...) distributed in
  # steps that get enabled or disabled depending on which step is currently
  # active.
  class ParticipatoryProcess < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::ScopableParticipatorySpace
    include Decidim::Followable
    include Decidim::HasReference
    include Decidim::Traceable
    include Decidim::HasPrivateUsers
    include Decidim::Loggable
    include Decidim::ParticipatorySpaceResourceable
    include Decidim::Searchable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource

    translatable_fields :title, :subtitle, :short_description, :description, :developer_group, :meta_scope, :local_area,
                        :target, :participatory_scope, :participatory_structure, :announcement

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :area,
               foreign_key: "decidim_area_id",
               class_name: "Decidim::Area",
               optional: true
    belongs_to :participatory_process_group,
               foreign_key: "decidim_participatory_process_group_id",
               class_name: "Decidim::ParticipatoryProcessGroup",
               inverse_of: :participatory_processes,
               optional: true
    has_many :steps,
             -> { order(position: :asc) },
             foreign_key: "decidim_participatory_process_id",
             class_name: "Decidim::ParticipatoryProcessStep",
             dependent: :destroy,
             inverse_of: :participatory_process
    has_one :active_step,
            -> { where(active: true) },
            foreign_key: "decidim_participatory_process_id",
            class_name: "Decidim::ParticipatoryProcessStep",
            dependent: :destroy,
            inverse_of: :participatory_process
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space
    belongs_to :scope_type_max_depth,
               foreign_key: "decidim_scope_type_id",
               class_name: "Decidim::ScopeType",
               optional: true

    has_many :components, as: :participatory_space, dependent: :destroy

    attr_readonly :active_step

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }

    validates_upload :hero_image
    mount_uploader :hero_image, Decidim::HeroImageUploader

    validates_upload :banner_image
    mount_uploader :banner_image, Decidim::BannerImageUploader

    scope :past, -> { where(arel_table[:end_date].lt(Date.current)) }
    scope :upcoming, -> { where(arel_table[:start_date].gt(Date.current)) }
    scope :active, -> { where(arel_table[:start_date].lteq(Date.current).and(arel_table[:end_date].gt(Date.current).or(arel_table[:end_date].eq(nil)))) }

    searchable_fields({
                        scope_id: :decidim_scope_id,
                        participatory_space: :itself,
                        A: :title,
                        B: :subtitle,
                        C: :short_description,
                        D: :description,
                        datetime: :published_at
                      },
                      index_on_create: ->(_process) { false },
                      index_on_update: ->(process) { process.visible? })

    # Scope to return only the promoted processes.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    # Return processes that DON'T belong to a process group.
    def self.groupless
      where(decidim_participatory_process_group_id: nil)
    end

    # Return processes that belong to a process group.
    def self.grouped
      where.not(decidim_participatory_process_group_id: nil)
    end

    def self.active_spaces
      active
    end

    def self.future_spaces
      upcoming
    end

    def self.past_spaces
      past
    end

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessPresenter
    end

    def active?
      return false if start_date.blank?

      start_date < Date.current && (end_date.blank? || end_date > Date.current)
    end

    def past?
      return false if end_date.blank?

      end_date < Date.current
    end

    def upcoming?
      return false if start_date.blank?

      start_date > Date.current
    end

    # Pluck all ParticipatoryProcessGroup ID's
    def self.group_ids
      pluck(:decidim_participatory_process_group_id)
    end

    def closed?
      past?
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end

    # Overrides the method from `Participable`.
    def moderators
      "#{admin_module_name}::Moderators".constantize.for(self)
    end

    def user_roles(role_name = nil)
      roles = Decidim::ParticipatoryProcessUserRole.where(participatory_process: self)
      return roles if role_name.blank?

      roles.where(role: role_name)
    end

    def attachment_context
      :admin
    end

    # Allow ransacker to search for a key in a hstore column (`title`.`en`)
    ransacker :title do |parent|
      Arel::Nodes::InfixOperation.new("->>", parent.table[:title], Arel::Nodes.build_quoted(I18n.locale.to_s))
    end
  end
end
