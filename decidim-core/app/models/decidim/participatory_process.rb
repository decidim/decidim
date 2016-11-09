# frozen_string_literal: true
module Decidim
  # Interaction between a user and an organization is done via a
  # ParticipatoryProcess. It's a unit of action from the Organization point of
  # view that groups several features (proposals, debates...) distributed in
  # steps that get enabled or disabled depending on which step is currently
  # active.
  class ParticipatoryProcess < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization
    has_many :steps, -> { order(position: :asc) }, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcessStep
    has_one :active_step, -> { where(active: true) }, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcessStep

    attr_readonly :active_step

    validates :slug, presence: true
    validate :slug_uniqueness

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::BannerImageUploader

    # Scope to return only the published processes.
    #
    # Returns an ActiveRecord::Relation.
    def self.published
      where.not(published_at: nil)
    end

    # Scope to return only the promoted processes.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    # Checks whether the process has been published or not.
    #
    # Returns a boolean.
    def published?
      published_at.present?
    end

    private

    def slug_uniqueness
      others = ParticipatoryProcess
        .where(organization: organization, slug: slug)
        .where.not(id: id)

      errors.add(:slug, :taken) if others.any?
    end
  end
end
