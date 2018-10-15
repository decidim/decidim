# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization can be done via an Conference.
  # It's a unit of action from the Organization point of view that groups
  # several components (proposals, debates...) that can be enabled or disabled.
  #
  class Conference < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Followable
    include Decidim::HasReference
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::ParticipatorySpaceResourceable

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

    has_many :speakers,
             foreign_key: "decidim_conference_id",
             class_name: "Decidim::ConferenceSpeaker",
             dependent: :destroy

    has_many :partners,
             foreign_key: "decidim_conference_id",
             class_name: "Decidim::Conferences::Partner",
             dependent: :destroy

    has_many :conference_registrations, class_name: "Decidim::Conferences::ConferenceRegistration", foreign_key: "decidim_conference_id", dependent: :destroy

    has_many :conference_invites, class_name: "Decidim::Conferences::ConferenceInvite",
                                  foreign_key: "decidim_conference_id", dependent: :destroy

    has_many :components, as: :participatory_space, dependent: :destroy

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Conference.slug_format }

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::HomepageImageUploader

    # Scope to return only the promoted conferences.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    def self.log_presenter_class_for(_log)
      Decidim::Conferences::AdminLog::ConferencePresenter
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end

    def has_registration_for?(user)
      conference_registrations.where(user: user).any?
    end

    def has_available_slots?
      return true if available_slots.zero?
      available_slots > conference_registrations.count
    end

    def remaining_slots
      available_slots - conference_registrations.count
    end
  end
end
