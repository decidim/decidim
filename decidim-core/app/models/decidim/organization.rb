# frozen_string_literal: true

module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    include TranslationsHelper
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource
    include Decidim::ActsAsAuthor

    SOCIAL_HANDLERS = [:twitter, :facebook, :instagram, :youtube, :github].freeze
    AVAILABLE_MACHINE_TRANSLATION_DISPLAY_PRIORITIES = %w(original translation).freeze

    translatable_fields :name, :description, :omnipresent_banner_title, :omnipresent_banner_short_description,
                        :highlighted_content_banner_title, :highlighted_content_banner_short_description, :highlighted_content_banner_action_title,
                        :highlighted_content_banner_action_subtitle, :welcome_notification_subject, :welcome_notification_body, :id_documents_explanation_text,
                        :admin_terms_of_service_body

    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: "Decidim::StaticPage", inverse_of: :organization, dependent: :destroy
    has_many :static_page_topics, class_name: "Decidim::StaticPageTopic", inverse_of: :organization, dependent: :destroy
    has_many :scopes, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Scope", inverse_of: :organization, dependent: :destroy
    has_many :scope_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::ScopeType", inverse_of: :organization, dependent: :destroy
    has_many :areas, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::Area", inverse_of: :organization, dependent: :destroy
    has_many :area_types, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::AreaType", inverse_of: :organization, dependent: :destroy
    has_many :admins, -> { where(admin: true) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
    has_many :users_with_any_role, -> { where.not(roles: []) }, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
    has_many :users, foreign_key: "decidim_organization_id", class_name: "Decidim::User", dependent: :destroy
    has_many :user_entities, foreign_key: "decidim_organization_id", class_name: "Decidim::UserBaseEntity", dependent: :destroy
    has_many :oauth_applications, foreign_key: "decidim_organization_id", class_name: "Decidim::OAuthApplication", inverse_of: :organization, dependent: :destroy
    has_many :hashtags, foreign_key: "decidim_organization_id", class_name: "Decidim::Hashtag", dependent: :destroy

    has_many :templates, foreign_key: "decidim_organization_id", class_name: "Decidim::Templates::Template", dependent: :destroy if defined? Decidim::Templates

    has_many :taxonomies, foreign_key: "decidim_organization_id", class_name: "Decidim::Taxonomy", inverse_of: :organization, dependent: :destroy

    # Users registration mode. Whether users can register or access the system. Does not affect users that access through Omniauth integrations.
    #  enabled: Users registration and sign in are enabled (default value).
    #  existing: Users cannot be registered in the system. Only existing users can sign in.
    #  disable: Users cannot register or sign in.
    enum users_registration_mode: [:enabled, :existing, :disabled], _prefix: true

    validates :host, uniqueness: true
    validates :reference_prefix, presence: true
    validates :time_zone, presence: true, time_zone: true
    validates :default_locale, inclusion: { in: :available_locales }

    has_one_attached :official_img_footer
    validates_upload :official_img_footer, uploader: Decidim::OfficialImageFooterUploader

    has_one_attached :logo
    validates_upload :logo, uploader: Decidim::OrganizationLogoUploader

    has_one_attached :favicon
    validates_upload :favicon, uploader: Decidim::OrganizationFaviconUploader

    has_one_attached :highlighted_content_banner_image
    validates_upload :highlighted_content_banner_image, uploader: Decidim::ImageUploader

    has_many_attached :open_data_files

    validate :unique_name

    def unique_name
      base_query = new_record? ? Decidim::Organization.all : Decidim::Organization.where.not(id:).all

      organization_names = []

      base_query.pluck(:name).each do |value|
        organization_names += value.except("machine_translations").values
        organization_names += value.fetch("machine_translations", {}).values
      end

      organization_names = organization_names.map(&:downcase).compact_blank

      name.each do |language, value|
        next if value.is_a?(Hash)

        errors.add("name_#{language}", :taken) if organization_names.include?(value.downcase)
      end
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::OrganizationPresenter
    end

    def settings
      Decidim::OrganizationSettings.for(self)
    end

    # This is needed for the upload validations
    def maximum_upload_size
      settings.upload_maximum_file_size
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

    def participatory_spaces
      @participatory_spaces ||= Decidim.participatory_space_manifests.flat_map do |manifest|
        manifest.participatory_spaces.call(self)
      end
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

    def admin_terms_of_service_body
      self[:admin_terms_of_service_body] ||
        multi_translation("decidim.admin_terms_of_service.default_body", available_locales)
    end

    def sign_up_enabled?
      users_registration_mode_enabled?
    end

    def sign_in_enabled?
      !users_registration_mode_disabled?
    end

    def open_data_file_path(resource = nil)
      return "#{host}-open-data.zip" if resource.nil?

      "#{host}-open-data-#{resource}.csv"
    end

    def enabled_omniauth_providers
      return Decidim::OmniauthProvider.enabled || {} if omniauth_settings.nil?

      default_except_disabled = Decidim::OmniauthProvider.enabled.except(*tenant_disabled_providers_keys)
      default_except_disabled.merge(tenant_enabled_providers)
    end

    def machine_translation_prioritizes_original?
      machine_translation_display_priority == "original"
    end

    def machine_translation_prioritizes_translation?
      machine_translation_display_priority == "translation"
    end

    # Returns the presenter for this author, to be used in the views.
    # Required by ActsAsAuthor.
    def presenter
      Decidim::OfficialAuthorPresenter.new
    end

    def static_pages_accessible_for(user)
      static_pages.accessible_for(self, user)
    end

    def favicon_ico
      return unless favicon.attached?
      return favicon if favicon.content_type == "image/vnd.microsoft.icon"

      uploader = attached_uploader(:favicon)

      pp uploader.inspect
      pp uploader.variant(:favicon).inspect
      pp uploader.variant(:favicon).processed.inspect
      pp uploader.variant(:favicon).processed.image.inspect


      variant = uploader.variant(:favicon)
      variant.processed.image
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

      tenant_enabled_providers_keys.index_with do |key|
        omniauth_provider_settings(key)
      end
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
