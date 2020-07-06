# frozen_string_literal: true

module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    include TranslationsHelper
    include Decidim::Traceable
    include Decidim::Loggable

    SOCIAL_HANDLERS = [:twitter, :facebook, :instagram, :youtube, :github].freeze

    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: "Decidim::StaticPage", inverse_of: :organization, dependent: :destroy
    has_many :static_page_topics, foreign_key: "organization_id", class_name: "Decidim::StaticPageTopic", inverse_of: :organization, dependent: :destroy
    has_many :scopes, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Scope", inverse_of: :organization
    has_many :scope_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::ScopeType", inverse_of: :organization
    has_many :areas, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Area", inverse_of: :organization
    has_many :area_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::AreaType", inverse_of: :organization
    has_many :admins, -> { where(admin: true) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User"
    has_many :users_with_any_role, -> { where.not(roles: []) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User"
    has_many :users, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
    has_many :oauth_applications, foreign_key: "decidim_organization_id", class_name: "Decidim::OAuthApplication", inverse_of: :organization, dependent: :destroy
    has_many :hashtags, foreign_key: "decidim_organization_id", class_name: "Decidim::Hashtag", dependent: :destroy

    # Users registration mode. Whether users can register or access the system. Doesn't affect users that access through Omniauth integrations.
    #  enabled: Users registration and sign in are enabled (default value).
    #  existing: Users can't be registered in the system. Only existing users can sign in.
    #  disable: Users can't register or sign in.
    enum users_registration_mode: [:enabled, :existing, :disabled], _prefix: true

    validates :name, :host, uniqueness: true
    validates :reference_prefix, presence: true
    validates :time_zone, presence: true, time_zone: true
    validates :default_locale, inclusion: { in: :available_locales }

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

    def public_participatory_spaces
      @public_participatory_spaces ||= Decidim.participatory_space_manifests.flat_map do |manifest|
        manifest.participatory_spaces.call(self).public_spaces
      end
    end

    def published_components
      @published_components ||= Component.where(participatory_space: public_participatory_spaces).published
    end

    def customize_welcome_notification
      self[:welcome_notification_subject].present? || self[:welcome_notification_body].present?
    end

    def welcome_notification_subject
      self[:welcome_notification_subject] ||
        multi_translation("decidim.welcome_notification.default_subject", available_locales)
    end

    def welcome_notification_body
      self[:welcome_notification_body] ||
        multi_translation("decidim.welcome_notification.default_body", available_locales)
    end

    def admin_terms_of_use_body
      self[:admin_terms_of_use_body] ||
        multi_translation("decidim.admin_terms_of_use.default_body", available_locales)
    end

    def sign_up_enabled?
      users_registration_mode_enabled?
    end

    def sign_in_enabled?
      !users_registration_mode_disabled?
    end

    def open_data_file
      @open_data_file ||= OpenDataUploader.new.tap do |uploader|
        uploader.retrieve_from_store! open_data_file_path
        uploader.cache! open_data_file_path
      end
    end

    def open_data_file_path
      "#{host}-open-data.zip"
    end

    def enabled_omniauth_providers
      return Decidim::OmniauthProvider.enabled || {} if omniauth_settings.nil?

      default_except_disabled = Decidim::OmniauthProvider.enabled.except(*tenant_disabled_providers_keys)
      default_except_disabled.merge(tenant_enabled_providers)
    end

    private

    def tenant_disabled_providers_keys
      omniauth_settings.collect do |key, value|
        next unless key.match?(/omniauth_settings_.*_enabled/) && value == false

        Decidim::OmniauthProvider.extract_provider_key(key)
      end.compact.uniq
    end

    def tenant_enabled_providers
      tenant_enabled_providers_keys = omniauth_settings.map do |key, value|
        next unless key.match?(/omniauth_settings_.*_enabled/) && value == true

        Decidim::OmniauthProvider.extract_provider_key(key)
      end.compact.uniq

      Hash[tenant_enabled_providers_keys.map do |key|
        [key, omniauth_provider_settings(key)]
      end]
    end

    def omniauth_provider_settings(provider)
      @omniauth_provider_settings ||= Hash.new do |hash, provider_key|
        hash[provider_key] = begin
          omniauth_settings.each_with_object({}) do |(key, value), provider_settings|
            next unless key.to_s.include?(provider_key.to_s)

            value = Decidim::AttributeEncryptor.decrypt(value) if Decidim::OmniauthProvider.value_defined?(value)
            setting_key = Decidim::OmniauthProvider.extract_setting_key(key, provider_key)

            provider_settings[setting_key] = value
          end
        end
      end
      @omniauth_provider_settings[provider]
    end
  end
end
