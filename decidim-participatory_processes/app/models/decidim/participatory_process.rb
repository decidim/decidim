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
    include Decidim::Scopable
    include Decidim::Followable
    include Decidim::HasReference
    include Decidim::Traceable
    include Decidim::HasPrivateUsers
    include Decidim::Loggable
    include Decidim::ParticipatorySpaceResourceable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
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

    has_many :components, as: :participatory_space, dependent: :destroy

    attr_readonly :active_step

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::BannerImageUploader

    scope :past, -> { where(arel_table[:end_date].lteq(Date.current)) }
    scope :upcoming, -> { where(arel_table[:start_date].gt(Date.current)) }
    scope :active, -> { where(arel_table[:start_date].lteq(Date.current).and(arel_table[:end_date].gt(Date.current).or(arel_table[:end_date].eq(nil)))) }

    # Scope to return only the promoted processes.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessPresenter
    end

    def past?
      return false if end_date.blank?
      end_date < Date.current
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end

    def self.private_processes
      where(private_space: true)
    end

    def can_participate?(user)
      return true unless private_space?
      return true if private_space? && users.include?(user)
      false
    end

    # Overrides the method from `Participable`.
    def moderators
      "#{admin_module_name}::Moderators".constantize.for(self)
    end
  end
end
