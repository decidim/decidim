# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization can be done via a Conference.
  # It is a unit of action from the Organization point of view that groups
  # several components (proposals, debates...) that can be enabled or disabled.
  #
  class Conference < ApplicationRecord
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
    include Decidim::Searchable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource
    include Decidim::FilterableResource
    include Decidim::ShareableWithToken

    translatable_fields :title, :slogan, :short_description, :description, :objectives, :registration_terms

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

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

    has_many :media_links, class_name: "Decidim::Conferences::MediaLink", foreign_key: "decidim_conference_id", dependent: :destroy
    has_many :registration_types, class_name: "Decidim::Conferences::RegistrationType", foreign_key: "decidim_conference_id", dependent: :destroy

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Conference.slug_format }

    has_one_attached :hero_image
    validates_upload :hero_image, uploader: Decidim::HeroImageUploader

    has_one_attached :banner_image
    validates_upload :banner_image, uploader: Decidim::BannerImageUploader

    has_one_attached :main_logo
    validates_upload :main_logo, uploader: Decidim::Conferences::DiplomaUploader

    has_one_attached :signature
    validates_upload :signature, uploader: Decidim::Conferences::DiplomaUploader

    searchable_fields({
                        scope_id: :decidim_scope_id,
                        participatory_space: :itself,
                        A: :title,
                        B: :slogan,
                        C: :short_description,
                        D: [:description, :objectives],
                        datetime: :published_at
                      },
                      index_on_create: ->(_conference) { false },
                      index_on_update: ->(conference) { conference.visible? })

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
      conference_registrations.where(user:).any?
    end

    def has_registration_for_user_and_registration_type?(user, registration_type)
      conference_registrations.where(user:, registration_type:).any?
    end

    def has_available_slots?
      return true if available_slots.zero?

      available_slots > conference_registrations.count
    end

    def has_published_registration_types?
      return false if registration_types.empty?

      registration_types.any?(&:published_at?)
    end

    def remaining_slots
      available_slots - conference_registrations.count
    end

    def diploma_sent?
      return false if diploma_sent_at.nil?

      true
    end

    def closed?
      return false if end_date.blank?

      end_date < Date.current
    end

    def user_roles(role_name = nil)
      roles = Decidim::ConferenceUserRole.where(conference: self)
      return roles if role_name.blank?

      roles.where(role: role_name)
    end

    def attachment_context
      :admin
    end

    def shareable_url(share_token)
      EngineRouter.main_proxy(self).conference_url(self, share_token: share_token.token)
    end

    # Allow ransacker to search for a key in a hstore column (`title`.`en`)
    ransacker_i18n :title
  end
end
