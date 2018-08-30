# frozen_string_literal: true

module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    SOCIAL_HANDLERS = [:twitter, :facebook, :instagram, :youtube, :github].freeze

    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: "Decidim::StaticPage", inverse_of: :organization, dependent: :destroy
    has_many :scopes, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Scope", inverse_of: :organization
    has_many :scope_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::ScopeType", inverse_of: :organization
    has_many :areas, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Area", inverse_of: :organization
    has_many :area_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::AreaType", inverse_of: :organization
    has_many :admins, -> { where(admin: true) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User"
    has_many :users_with_any_role, -> { where.not(roles: []) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User"
    has_many :users, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
    has_many :oauth_applications, foreign_key: "decidim_organization_id", class_name: "Decidim::OAuthApplication", inverse_of: :organization, dependent: :destroy
    has_many :hashtags, foreign_key: "decidim_organization_id", class_name: "Decidim::Hashtag", dependent: :destroy

    validates :name, :host, uniqueness: true
    validates :reference_prefix, presence: true
    validates :default_locale, inclusion: { in: :available_locales }

    mount_uploader :homepage_image, Decidim::HomepageImageUploader
    mount_uploader :official_img_header, Decidim::OfficialImageHeaderUploader
    mount_uploader :official_img_footer, Decidim::OfficialImageFooterUploader
    mount_uploader :logo, Decidim::OrganizationLogoUploader
    mount_uploader :favicon, Decidim::OrganizationFaviconUploader
    mount_uploader :highlighted_content_banner_image, ImageUploader

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::OrganizationPresenter
    end

    def available_authorization_handlers
      available_authorizations & Decidim.authorization_handlers.map(&:name)
    end

    # Returns top level scopes for this organization.
    #
    # Returns an ActiveRecord::Relation.
    def top_scopes
      @top_scopes ||= scopes.top_level
    end

    def homepage_big_url
      homepage_image.big.url
    end

    def public_participatory_spaces
      @public_participatory_spaces ||= Decidim.participatory_space_manifests.flat_map do |manifest|
        manifest.participatory_spaces.call(self).public_spaces
      end
    end

    def published_components
      @published_components ||= Component.where(participatory_space: public_participatory_spaces).published
    end
  end
end
