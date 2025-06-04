# frozen_string_literal: true

require "decidim/core/engine"
require "decidim/core/api"
require "decidim/core/version"

# Decidim configuration.
module Decidim
  autoload :Env, "decidim/env"
  autoload :Deprecations, "decidim/deprecations"
  autoload :ActsAsAuthor, "decidim/acts_as_author"
  autoload :ActsAsTree, "decidim/acts_as_tree"
  autoload :TranslatableAttributes, "decidim/translatable_attributes"
  autoload :TranslatableResource, "decidim/translatable_resource"
  autoload :JsonbAttributes, "decidim/jsonb_attributes"
  autoload :LegacyFormBuilder, "decidim/legacy_form_builder"
  autoload :FormBuilder, "decidim/form_builder"
  autoload :AuthorizationFormBuilder, "decidim/authorization_form_builder"
  autoload :FilterFormBuilder, "decidim/filter_form_builder"
  autoload :ComponentManifest, "decidim/component_manifest"
  autoload :NotificationSettingManifest, "decidim/notification_setting_manifest"
  autoload :ParticipatorySpaceManifest, "decidim/participatory_space_manifest"
  autoload :ResourceManifest, "decidim/resource_manifest"
  autoload :Resourceable, "decidim/resourceable"
  autoload :Traceable, "decidim/traceable"
  autoload :Loggable, "decidim/loggable"
  autoload :Reportable, "decidim/reportable"
  autoload :UserReportable, "decidim/user_reportable"
  autoload :Authorable, "decidim/authorable"
  autoload :Coauthorable, "decidim/coauthorable"
  autoload :Participable, "decidim/participable"
  autoload :Publicable, "decidim/publicable"
  autoload :Taxonomizable, "decidim/taxonomizable"
  autoload :Scopable, "decidim/scopable"
  autoload :ScopableParticipatorySpace, "decidim/scopable_participatory_space"
  autoload :ScopableComponent, "decidim/scopable_component"
  autoload :ScopableResource, "decidim/scopable_resource"
  autoload :ContentParsers, "decidim/content_parsers"
  autoload :ContentRenderers, "decidim/content_renderers"
  autoload :ContentProcessor, "decidim/content_processor"
  autoload :Components, "decidim/components"
  autoload :HasAttachmentCollections, "decidim/has_attachment_collections"
  autoload :HasAttachments, "decidim/has_attachments"
  autoload :ComponentValidator, "decidim/component_validator"
  autoload :HasSettings, "decidim/has_settings"
  autoload :HasTaxonomySettings, "decidim/has_taxonomy_settings"
  autoload :HasComponent, "decidim/has_component"
  autoload :HasCategory, "decidim/has_category"
  autoload :Followable, "decidim/followable"
  autoload :FriendlyDates, "decidim/friendly_dates"
  autoload :Nicknamizable, "decidim/nicknamizable"
  autoload :HasReference, "decidim/has_reference"
  autoload :StatsRegistry, "decidim/stats_registry"
  autoload :Exporters, "decidim/exporters"
  autoload :FileZipper, "decidim/file_zipper"
  autoload :Menu, "decidim/menu"
  autoload :MenuItem, "decidim/menu_item"
  autoload :MenuRegistry, "decidim/menu_registry"
  autoload :AdminFilter, "decidim/admin_filter"
  autoload :AdminFiltersRegistry, "decidim/admin_filters_registry"
  autoload :ManifestRegistry, "decidim/manifest_registry"
  autoload :AssetRouter, "decidim/asset_router"
  autoload :EngineRouter, "decidim/engine_router"
  autoload :UrlOptionResolver, "decidim/url_option_resolver"
  autoload :Events, "decidim/events"
  autoload :ViewHooks, "decidim/view_hooks"
  autoload :ContentBlockRegistry, "decidim/content_block_registry"
  autoload :ContentBlockManifest, "decidim/content_block_manifest"
  autoload :ContentBlocks, "decidim/content_blocks"
  autoload :AttributeEncryptor, "decidim/attribute_encryptor"
  autoload :NewsletterEncryptor, "decidim/newsletter_encryptor"
  autoload :NewsletterParticipant, "decidim/newsletter_participant"
  autoload :Searchable, "decidim/searchable"
  autoload :FilterableResource, "decidim/filterable_resource"
  autoload :SearchResourceFieldsMapper, "decidim/search_resource_fields_mapper"
  autoload :QueryExtensions, "decidim/query_extensions"
  autoload :ParticipatorySpaceResourceable, "decidim/participatory_space_resourceable"
  autoload :HasPrivateUsers, "decidim/has_private_users"
  autoload :ViewModel, "decidim/view_model"
  autoload :FingerprintCalculator, "decidim/fingerprint_calculator"
  autoload :Fingerprintable, "decidim/fingerprintable"
  autoload :DownloadYourData, "decidim/download_your_data"
  autoload :DownloadYourDataSerializers, "decidim/download_your_data_serializers"
  autoload :DownloadYourDataExporter, "decidim/download_your_data_exporter"
  autoload :Amendable, "decidim/amendable"
  autoload :Gamification, "decidim/gamification"
  autoload :Hashtag, "decidim/hashtag"
  autoload :Etherpad, "decidim/etherpad"
  autoload :Paddable, "decidim/paddable"
  autoload :OpenDataExporter, "decidim/open_data_exporter"
  autoload :IoEncoder, "decidim/io_encoder"
  autoload :HasResourcePermission, "decidim/has_resource_permission"
  autoload :PermissionsRegistry, "decidim/permissions_registry"
  autoload :Randomable, "decidim/randomable"
  autoload :Likeable, "decidim/likeable"
  autoload :ActionAuthorization, "decidim/action_authorization"
  autoload :Map, "decidim/map"
  autoload :Geocodable, "decidim/geocodable"
  autoload :Snippets, "decidim/snippets"
  autoload :OrganizationSettings, "decidim/organization_settings"
  autoload :HasUploadValidations, "decidim/has_upload_validations"
  autoload :FileValidatorHumanizer, "decidim/file_validator_humanizer"
  autoload :ShareableWithToken, "decidim/shareable_with_token"
  autoload :RecordEncryptor, "decidim/record_encryptor"
  autoload :AttachmentAttributes, "decidim/attachment_attributes"
  autoload :ReminderRegistry, "decidim/reminder_registry"
  autoload :ReminderManifest, "decidim/reminder_manifest"
  autoload :ManifestMessages, "decidim/manifest_messages"
  autoload :CommonPasswords, "decidim/common_passwords"
  autoload :HasArea, "decidim/has_area"
  autoload :AttributeObject, "decidim/attribute_object"
  autoload :Query, "decidim/query"
  autoload :Command, "decidim/command"
  autoload :SocialShareServiceManifest, "decidim/social_share_service_manifest"
  autoload :EventRecorder, "decidim/event_recorder"
  autoload :ControllerHelpers, "decidim/controller_helpers"
  autoload :ProcessesFileLocally, "decidim/processes_file_locally"
  autoload :BlockRegistry, "decidim/block_registry"
  autoload :DependencyResolver, "decidim/dependency_resolver"
  autoload :Upgrade, "decidim/upgrade"
  autoload :ParticipatorySpaceUser, "decidim/participatory_space_user"
  autoload :ModerationTools, "decidim/moderation_tools"
  autoload :ContentSecurityPolicy, "decidim/content_security_policy"
  autoload :IconRegistry, "decidim/icon_registry"
  autoload :HasConversations, "decidim/has_conversations"
  autoload :SoftDeletable, "decidim/soft_deletable"
  autoload :PrivateDownloadHelper, "decidim/private_download_helper"
  autoload :PdfSignatureExample, "decidim/pdf_signature_example"
  autoload :HasWorkflows, "decidim/has_workflows"
  autoload :StatsFollowersCount, "decidim/stats_followers_count"
  autoload :StatsParticipantsCount, "decidim/stats_participants_count"
  autoload :ActionAuthorizationHelper, "decidim/action_authorization_helper"
  autoload :ResourceHelper, "decidim/resource_helper"

  module Commands
    autoload :CreateResource, "decidim/commands/create_resource"
    autoload :UpdateResource, "decidim/commands/update_resource"
    autoload :DestroyResource, "decidim/commands/destroy_resource"
    autoload :ResourceHandler, "decidim/commands/resource_handler"
    autoload :HookError, "decidim/commands/hook_error"
    autoload :SoftDeleteResource, "decidim/commands/soft_delete_resource"
    autoload :RestoreResource, "decidim/commands/restore_resource"
  end

  include ActiveSupport::Configurable
  # Loads seeds from all engines.
  def self.seed!
    # After running the migrations, some records may have loaded their column
    # caches at different stages of the migration process, so in order to
    # prevent any "undefined method" errors if these tasks are run
    # consecutively, reset the column cache before the migrations.
    reset_all_column_information

    # Faker needs to have the `:en` locale in order to work properly, so we
    # must enforce it during the seeds.
    original_locale = I18n.available_locales
    I18n.available_locales = original_locale + [:en] unless original_locale.include?(:en)

    Rails.application.railties.to_a.uniq.each do |railtie|
      next unless railtie.respond_to?(:load_seed) && railtie.class.name.include?("Decidim::")

      railtie.load_seed
    end

    participatory_space_manifests.each do |manifest|
      manifest.seed!

      seed_contextual_help_sections!(manifest)
    end

    seed_gamification_badges!

    seed_likes!

    I18n.available_locales = original_locale
  end

  def self.seed_contextual_help_sections!(manifest)
    Organization.all.each do |organization|
      ContextualHelpSection.set_content(
        organization,
        manifest.name,
        Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.sentence(word_count: 15)
        end
      )
    end
  end

  def self.seed_gamification_badges!
    Gamification.badges.each do |badge|
      puts "Setting random values for the \"#{badge.name}\" badge..." # rubocop:disable Rails/Output
      User.all.find_each do |user|
        Gamification::BadgeScore.find_or_create_by!(
          user:,
          badge_name: badge.name,
          value: Random.rand(0...20)
        )
      end
    end
  end

  def self.seed_likes!
    resources_types = Decidim.resource_manifests
                             .map { |resource| resource.attributes[:model_class_name] }
                             .select { |resource| resource.constantize.include? Decidim::Likeable }

    resources_types.each do |resource_type|
      resource_type.constantize.find_each do |resource|
        # exclude the users that already liked
        users = resource.likes.map(&:author)
        remaining_count = Decidim::User.count - users.count
        next if remaining_count < 1

        rand([50, remaining_count].min).times do
          user = (Decidim::User.all - users).sample
          next unless user

          Decidim::Like.create!(resource:, author: user)
          users << user
        end
      end
    end
  end

  # Finds all currently loaded Decidim ActiveRecord classes and resets their
  # column information.
  def self.reset_all_column_information
    ActiveRecord::Base.descendants.each do |cls|
      next if cls.name.nil? # abstract classes registered during tests
      next if cls.abstract_class? || !cls.name.match?(/^Decidim::/)

      cls.reset_column_information
    end
  end

  # Exposes a configuration option: The application name String.
  config_accessor :application_name do
    config.application_name = Decidim::Env.new("DECIDIM_APPLICATION_NAME", "My Application Name").to_s
  end

  # Exposes a configuration option: The email String to use as sender in all
  # the mails.
  config_accessor :mailer_sender do
    Decidim::Env.new("DECIDIM_MAILER_SENDER", "change-me@example.org").to_s
  end

  # Whether SSL should be forced or not.
  config_accessor :force_ssl do
    if Decidim::Env.new("DECIDIM_FORCE_SSL", "auto").default_or_present_if_exists.to_s == "auto"
      Rails.env.starts_with?("production") || Rails.env.starts_with?("staging")
    else
      Decidim::Env.new("DECIDIM_FORCE_SSL").present?
    end
  end

  # CDN host configuration
  config_accessor :storage_cdn_host do
    Decidim::Env.new("STORAGE_CDN_HOST", nil).to_s
  end

  # Which storage provider is going to be used for the application, provides support for the most popular options.
  config_accessor :storage_provider do
    Decidim::Env.new("STORAGE_PROVIDER", "local").to_s
  end

  # VAPID public key that will be used to sign the Push API requests.
  config_accessor :vapid_public_key do
    Decidim::Env.new("VAPID_PUBLIC_KEY", nil)
  end

  # VAPID private key that will be used to sign the Push API requests.
  config_accessor :vapid_private_key do
    Decidim::Env.new("VAPID_PRIVATE_KEY", nil)
  end

  # Having this on true will change the way the svg assets are being served.
  config_accessor :cors_enabled do
    Decidim::Env.new("DECIDIM_CORS_ENABLED", "false").present?
  end

  # Exposes a configuration option: The application available locales.
  config_accessor :available_locales do
    %w(en bg ar ca cs da de el eo es es-MX es-PY et eu fa fi-pl fi fr fr-CA ga gl hr hu id is it ja ko lb lt lv mt nl no pl pt pt-BR ro ru sk sl sr sv tr uk vi zh-CN zh-TW)
  end

  # Exposes a configuration option: The application default locale.
  config_accessor :default_locale do
    (Decidim::Env.new("DECIDIM_DEFAULT_LOCALE", "en").presence || :en).to_s
  end

  # Users that have not logged in for this period of time will be deleted
  config_accessor :delete_inactive_users_after_days do
    Decidim::Env.new("DELETE_INACTIVE_USERS_AFTER_DAYS", 365).to_i
  end

  # The minimum allowed inactivity period for deleting participants.
  config_accessor :minimum_inactivity_period do
    30
  end

  # Users will be warned for the first time this amount of days before the final removal
  config_accessor :delete_inactive_users_first_warning_days_before do
    30
  end

  # Users will be warned for the last time this amount of days before the final removal
  config_accessor :delete_inactive_users_last_warning_days_before do
    7
  end

  # Returns the inactivity threshold (in days) to trigger the first warning email.
  def self.first_warning_inactive_users_after_days
    delete_inactive_users_after_days - delete_inactive_users_first_warning_days_before
  end

  # Returns the inactivity threshold (in days) to trigger the final warning email.
  def self.last_warning_inactive_users_after_days
    delete_inactive_users_first_warning_days_before - delete_inactive_users_last_warning_days_before
  end

  # Disable the redirection to the external host when performing redirect back
  # For more details https://github.com/rails/rails/issues/39643
  # Additional context: This has been revealed as an issue during a security audit on Future of Europe installation
  config_accessor :allow_open_redirects do
    Decidim::Env.new("DECIDIM_ALLOW_OPEN_REDIRECTS").present?
  end

  # Exposes a configuration option: an array of symbols representing processors
  # that will be automatically executed when a content is parsed or rendered.
  #
  # A content processor is a concept to refer to a set of two classes:
  # the content parser class and the content renderer class.
  # e.g. If we register a content processor named `user`:
  #
  #   Decidim.content_processors += [:user]
  #
  # we must declare the following classes:
  #
  #   Decidim::ContentParsers::UserParser < BaseParser
  #   Decidim::ContentRenderers::UserRenderer < BaseRenderer
  config_accessor :content_processors do
    []
  end

  # Exposes a configuration option: an object to configure geocoder
  config_accessor :geocoder

  # Exposes a configuration option: an object to configure the mapping
  # functionality. See Decidim::Map for more information.
  config_accessor :maps

  # Exposes a configuration option: a custom method to generate references.
  # If overwritten, it should handle both component resources and participatory spaces.
  # Default: Calculates a unique reference for the model in
  # the following format:
  #
  # "BCN-PROP-2017-02-6589" which in this example translates to:
  #
  # BCN: A setting configured at the organization to be prepended to each reference.
  # PROP: Unique name identifier for a resource: Decidim::Proposals::Proposal
  #       (MEET for meetings or PROJ for projects).
  # 2017-02: Year-Month of the resource creation date
  # 6589: ID of the resource
  config_accessor :reference_generator do
    lambda do |resource, component|
      ref = ""

      if resource.is_a?(Decidim::HasComponent) && component.present?
        # It is a component resource
        ref = component.participatory_space.organization.reference_prefix
      elsif resource.is_a?(Decidim::Participable)
        # It is a participatory space
        ref = resource.organization.reference_prefix
      end

      class_identifier = resource.class.name.demodulize[0..3].upcase
      year_month = (resource.created_at || Time.current).strftime("%Y-%m")

      [ref, class_identifier, year_month, resource.id].join("-")
    end
  end

  # Exposes a configuration option: the IPs that are allowed to access the system
  config_accessor :system_accesslist_ips do
    Decidim::Env.new("DECIDIM_SYSTEM_ACCESSLIST_IPS").to_array
  end

  # Exposes a configuration option: the currency unit
  config_accessor :currency_unit do
    if Decidim::Env.new("DECIDIM_CURRENCY_UNIT", "€").present?
      Decidim::Env.new("DECIDIM_CURRENCY_UNIT", "€").to_s
    else
      "€"
    end
  end

  # Exposes a configuration option: The image uploader quality.
  config_accessor :image_uploader_quality do
    Decidim::Env.new("DECIDIM_IMAGE_UPLOADER_QUALITY", "80").to_i
  end

  # The number of reports which a resource can receive before hiding it
  config_accessor :max_reports_before_hiding do
    Decidim::Env.new("DECIDIM_MAX_REPORTS_BEFORE_HIDING", "3").to_i
  end

  # Allow organization's administrators to inject custom HTML into the frontend
  config_accessor :enable_html_header_snippets do
    Decidim::Env.new("DECIDIM_ENABLE_HTML_HEADER_SNIPPETS").present?
  end

  # Allow organization's administrators to track newsletter links
  config_accessor :track_newsletter_links do
    if Decidim::Env.new("DECIDIM_TRACK_NEWSLETTER_LINKS", "auto").default_or_present_if_exists.to_s == "auto"
      true
    else
      Decidim.force_ssl
    end
  end

  # Time that download your data files are available in server
  config_accessor :download_your_data_expiry_time do
    Decidim::Env.new("DECIDIM_DOWNLOAD_YOUR_DATA_EXPIRY_TIME", "7").to_i.days
  end

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  config_accessor :throttling_max_requests do
    Decidim::Env.new("DECIDIM_THROTTLING_MAX_REQUESTS", "100").to_i
  end

  # Time window in which the throttling is applied.
  config_accessor :throttling_period do
    Decidim::Env.new("DECIDIM_THROTTLING_PERIOD", "1").to_i.minutes
  end

  # Time window were users can access the website even if their email is not confirmed.
  config_accessor :unconfirmed_access_for do
    Decidim::Env.new("DECIDIM_UNCONFIRMED_ACCESS_FOR", "0").to_i.days
  end

  # Allow machine translations
  config_accessor :enable_machine_translations do
    false
  end

  # How long can a user remained logged in before the session expires. Notice that
  # this is also maximum time that user can idle before getting automatically signed out.
  config_accessor :expire_session_after do
    Decidim::Env.new("DECIDIM_EXPIRE_SESSION_AFTER", "30").to_i.minutes
  end

  # If set to true, users have option to "remember me". Notice that expire_session_after will not take
  # effect when the user wants to be remembered.
  config_accessor :enable_remember_me do
    if Decidim::Env.new("DECIDIM_ENABLE_REMEMBER_ME", "auto").default_or_present_if_exists.to_s == "auto"
      true
    else
      Decidim::Env.new("DECIDIM_ENABLE_REMEMBER_ME", "auto").default_or_present_if_exists
    end
  end

  # Defines how often session_timeouter.js checks time between current moment and last request
  config_accessor :session_timeout_interval do
    Decidim::Env.new("DECIDIM_SESSION_TIMEOUT_INTERVAL", "10").to_i.seconds
  end

  # Exposes a configuration option: an object to configure Etherpad
  config_accessor :etherpad do
    # {
    #   server: <your url>,
    #   api_key: <your key>,
    #   api_version: <your version>
    # }
  end

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  config_accessor :base_uploads_path do
    Decidim::Env.new("DECIDIM_BASE_UPLOADS_PATH").to_s if Decidim::Env.new("DECIDIM_BASE_UPLOADS_PATH").present?
  end

  # The name of the class to deliver SMS codes to users.
  #
  # Check the example in `decidim-verifications`.
  config_accessor :sms_gateway_service do
    # "MyGatewayClass"
  end

  # The name of the class used to generate a timestamp from a document.
  #
  # Check the example in `decidim-initiatives`
  config_accessor :timestamp_service do
    # "MyTimestampService"
  end

  # The name of the class used to process a pdf and add a signature to the
  # document.
  #
  # Check the example in `decidim-initiatives`
  config_accessor :pdf_signature_service do
    # "MyPDFSignatureService"
  end

  # The name of the class to translate user content.
  #
  config_accessor :machine_translation_service do
    # "MyTranslationService"
  end

  config_accessor :maximum_attachment_size do
    Decidim::Env.new("DECIDIM_MAXIMUM_ATTACHMENT_SIZE", "10").to_i
  end

  config_accessor :maximum_avatar_size do
    Decidim::Env.new("DECIDIM_MAXIMUM_AVATAR_SIZE", "5").to_i
  end

  # Social Networking services used for social sharing
  config_accessor :social_share_services do
    Decidim::Env.new("DECIDIM_SOCIAL_SHARE_SERVICES", "X, Facebook, WhatsApp, Telegram").to_array
  end

  # The Decidim::Exporters::CSV's default column separator
  config_accessor :default_csv_col_sep do
    Decidim::Env.new("DECIDIM_DEFAULT_CSV_COL_SEP", ";").to_s
  end

  # Exposes a configuration option: HTTP_X_FORWARDED_HOST header follow-up.
  # If a caching system is in place, it can also allow cache and log poisoning attacks,
  # allowing attackers to control the contents of caches and logs that could be used for other attacks.
  config_accessor :follow_http_x_forwarded_host do
    Decidim::Env.new("DECIDIM_FOLLOW_HTTP_X_FORWARDED_HOST").present?
  end

  # The list of roles a user can have, not considering the space-specific roles.
  config_accessor :user_roles do
    %w(admin user_manager)
  end

  # The list of visibility options for amendments. An Array of Strings that
  # serve both as locale keys and values to construct the input collection in
  # Decidim::Amendment::VisibilityStepSetting::options.
  #
  # This collection is used in Decidim::Admin::SettingsHelper to generate a
  # radio buttons collection input field form for a Decidim::Component
  # step setting :amendments_visibility.
  config_accessor :amendments_visibility_options do
    %w(all participants)
  end

  # Exposes a configuration option: The maximum length for conversation
  # messages.
  config_accessor :maximum_conversation_message_length do
    Decidim::Env.new("DECIDIM_MAXIMUM_CONVERSATION_MESSAGE_LENGTH", "1000").to_i
  end

  # Defines the name of the cookie used to check if the user has given consent
  # to store local data in their browser.
  config_accessor :consent_cookie_name do
    Decidim::Env.new("DECIDIM_CONSENT_COOKIE_NAME", "decidim-consent").to_s
  end

  # Defines data consent categories. Note that when adding an item you need to
  # add following i18n entries also (change 'foo' with the name of the data
  # which can be a cookie for instance).
  #
  # layouts.decidim.data_consent.details.items.foo.service
  # layouts.decidim.data_consent.details.items.foo.description
  config_accessor :consent_categories do
    [
      {
        slug: "essential",
        mandatory: true,
        items: [
          {
            type: "cookie",
            name: "_session_id"
          },
          {
            type: "cookie",
            name: Decidim.consent_cookie_name
          },
          {
            type: "local_storage",
            name: "pwaInstallPromptSeen"
          }
        ]
      },
      {
        slug: "preferences",
        mandatory: false
      },
      {
        slug: "analytics",
        mandatory: false
      },
      {
        slug: "marketing",
        mandatory: false
      }
    ]
  end

  # Denied passwords. Array may contain strings and regex entries.
  config_accessor :denied_passwords do
    Decidim::Env.new("DECIDIM_DENIED_PASSWORDS").to_array(separator: ", ")
  end

  # Ignores strings similar to email / domain on password validation if too short
  config_accessor :password_similarity_length do
    Decidim::Env.new("DECIDIM_PASSWORD_SIMILARITY_LENGTH", 4).to_i
  end

  # Defines if admins are required to have stronger passwords than other users
  config_accessor :admin_password_strong do
    Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_STRONG", true).present?
  end

  config_accessor :admin_password_expiration_days do
    Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS", 90).to_i
  end

  config_accessor :admin_password_min_length do
    Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_MIN_LENGTH", 15).to_i
  end

  config_accessor :admin_password_repetition_times do
    Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_REPETITION_TIMES", 5).to_i
  end

  # This is an internal key that allow us to properly configure the caching key separator. This is useful for redis cache store
  # as it creates some namespaces within the cached data.
  # use `config.cache_key_separator = ":"` in your initializer to have namespaced data
  config_accessor :cache_key_separator do
    Decidim::Env.new("DECIDIM_CACHE_KEY_SEPARATOR", "/").to_s
  end

  # This is the maximum time that the cache will be stored. If nil, the cache will be stored indefinitely.
  # Currently, cache is applied in the Cells where the method `cache_hash` is defined.
  config_accessor :cache_expiry_time do
    Decidim::Env.new("DECIDIM_CACHE_EXPIRATION_TIME", "1440").to_i.minutes
  end

  # Same as before, but specifically for cell displaying stats
  config_accessor :stats_cache_expiry_time do
    Decidim::Env.new("DECIDIM_STATS_CACHE_EXPIRATION_TIME", 10).to_i.minutes
  end

  # Enable/Disable the service worker
  config_accessor :service_worker_enabled do
    Decidim::Env.new("DECIDIM_SERVICE_WORKER_ENABLED", Rails.env.exclude?("development")).present?
  end

  # List of static pages' slugs that can include content blocks
  config_accessor :page_blocks do
    Decidim::Env.new("DECIDIM_PAGE_BLOCKS", "terms-of-service").to_array
  end

  # The default max last activity users to be shown
  config_accessor :default_max_last_activity_users do
    6
  end

  # List of additional content security policies to be appended to the default ones
  # This is useful for adding custom CSPs for external services like Here Maps, YouTube, etc.
  # Read more: https://docs.decidim.org/en/develop/configure/initializer#_content_security_policy
  config_accessor :content_security_policies_extra do
    {}
  end

  config_accessor :omniauth_providers do
    {
      developer: {
        enabled: Rails.env.local?,
        icon: "phone-line"
      },
      facebook: {
        enabled: Decidim::Env.new("OMNIAUTH_FACEBOOK_APP_ID").present?,
        app_id: Decidim::Env.new("OMNIAUTH_FACEBOOK_APP_ID", nil),
        app_secret: Decidim::Env.new("OMNIAUTH_FACEBOOK_APP_SECRET", nil),
        icon_path: "media/images/facebook.svg"
      },
      twitter: {
        enabled: Decidim::Env.new("OMNIAUTH_TWITTER_API_KEY").present?,
        api_key: Decidim::Env.new("OMNIAUTH_TWITTER_API_KEY", nil),
        api_secret: Decidim::Env.new("OMNIAUTH_TWITTER_API_SECRET", nil),
        icon_path: "media/images/twitter-x.svg"
      },
      google_oauth2: {
        enabled: Decidim::Env.new("OMNIAUTH_GOOGLE_CLIENT_ID").present?,
        icon_path: "media/images/google.svg",
        client_id: Decidim::Env.new("OMNIAUTH_GOOGLE_CLIENT_ID", nil),
        client_secret: Decidim::Env.new("OMNIAUTH_GOOGLE_CLIENT_SECRET", nil)
      }
    }
  end

  CoreDataManifest = Data.define(:name, :collection, :serializer, :include_in_open_data)

  def self.open_data_manifests
    [
      CoreDataManifest.new(
        name: :moderated_users,
        collection: lambda { |organization|
          Decidim::UserModeration.joins(:user).where(decidim_users: { decidim_organization_id: organization.id }).where.not(decidim_users: { blocked_at: nil })
        },
        serializer: Decidim::Exporters::OpenDataBlockedUserSerializer,
        include_in_open_data: true
      ),
      CoreDataManifest.new(
        name: :moderations,
        collection: ->(organization) { Decidim::Moderation.where(participatory_space: organization.participatory_spaces).includes(:reports).hidden },
        serializer: Decidim::Exporters::OpenDataModerationSerializer,
        include_in_open_data: true
      ),
      CoreDataManifest.new(
        name: :users,
        collection: ->(organization) { Decidim::User.where(organization:).confirmed.not_blocked.includes(avatar_attachment: :blob) },
        serializer: Decidim::Exporters::OpenDataUserSerializer,
        include_in_open_data: true
      ),
      CoreDataManifest.new(
        name: :taxonomies,
        collection: ->(organization) { Decidim::Taxonomy.where(organization:) },
        serializer: Decidim::Exporters::OpenDataTaxonomySerializer,
        include_in_open_data: true
      )
    ]
  end

  # Public: Registers a global engine. This method is intended to be used
  # by component engines that also offer unscoped functionality
  #
  # name    - The name of the engine to register. Should be unique.
  # engine  - The engine to register.
  # options - Options to pass to the engine.
  #           :at - The route to mount the engine to.
  #
  # Returns nothing.
  def self.register_global_engine(name, engine, options = {})
    return if global_engines.has_key?(name)

    options[:at] ||= "/#{name}"

    global_engines[name.to_sym] = {
      at: options[:at],
      engine:
    }
  end

  # Semiprivate: Removes a global engine from the registry. Mostly used on testing,
  # no real reason to use this on production.
  #
  # name - The name of the global engine to remove.
  #
  # Returns nothing.
  def self.unregister_global_engine(name)
    global_engines.delete(name.to_sym)
  end

  # Public: Finds all registered engines via the 'register_global_engine' method.
  #
  # Returns an Array[::Rails::Engine]
  def self.global_engines
    @global_engines ||= {}
  end

  # Public: Registers a component, usually held in an external library or in a
  # separate folder in the main repository. Exposes a DSL defined by
  # `Decidim::ComponentManifest`.
  #
  # Component manifests are held in a global registry and are used in all kinds of
  # places to figure out what new components or functionalities the component provides.
  #
  # name - A Symbol with the component's unique name.
  #
  # Returns nothing.
  def self.register_component(name, &)
    component_registry.register(name, &)
  end

  # Public: Registers a participatory space, usually held in an external library
  # or in a separate folder in the main repository. Exposes a DSL defined by
  # `Decidim::ParticipatorySpaceManifest`.
  #
  # Participatory space manifests are held in a global registry and are used in
  # all kinds of places to figure out what new components or functionalities the
  # participatory space provides.
  #
  # name - A Symbol with the participatory space's unique name.
  #
  # Returns nothing.
  def self.register_participatory_space(name, &)
    participatory_space_registry.register(name, &)
  end

  # Public: Registers a resource.
  #
  # Returns nothing.
  def self.register_resource(name, &)
    resource_registry.register(name, &)
  end

  # Public: Registers a social share service.
  #
  # Returns nothing.
  def self.register_social_share_service(name, &)
    social_share_services_registry.register(name, &)
  end

  # Public: Registers a notification setting.
  #
  # Returns nothing.
  def self.notification_settings(name, &)
    notification_settings_registry.register(name, &)
  end

  # Public: Finds all registered resource manifests via the `register_component`
  # method.
  #
  # Returns an Array[ResourceManifest].
  def self.resource_manifests
    resource_registry.manifests
  end

  # Public: Finds all registered component manifest's via the `register_component`
  # method.
  #
  # Returns an Array[ComponentManifest].
  def self.component_manifests
    component_registry.manifests.sort_by(&:name)
  end

  # Public: Finds all registered participatory space manifest's via the
  # `register_participatory_space` method.
  #
  # Returns an Array[ParticipatorySpaceManifest].
  def self.participatory_space_manifests
    participatory_space_registry.manifests
  end

  # Public: Finds a component manifest by the component's name.
  #
  # name - The name of the ComponentManifest to find.
  #
  # Returns a ComponentManifest if found, nil otherwise.
  def self.find_component_manifest(name)
    component_registry.find(name.to_sym)
  end

  # Public: Finds a participatory space manifest by the participatory space's
  # name.
  #
  # name - The name of the ParticipatorySpaceManifest to find.
  #
  # Returns a ParticipatorySpaceManifest if found, nil otherwise.
  def self.find_participatory_space_manifest(name)
    participatory_space_registry.find(name.to_sym)
  end

  # Public: Finds a resource manifest by the resource's name.
  #
  # resource_name_or_class - The String of the ResourceManifest name or the class of
  # the ResourceManifest model_class to find.
  #
  # Returns a ResourceManifest if found, nil otherwise.
  def self.find_resource_manifest(resource_name_or_klass)
    resource_registry.find(resource_name_or_klass)
  end

  # Public: Stores the registry of components
  def self.component_registry
    @component_registry ||= ManifestRegistry.new(:components)
  end

  # Public: Stores the registry of participatory spaces
  def self.participatory_space_registry
    @participatory_space_registry ||= ManifestRegistry.new(:participatory_spaces)
  end

  # Public: Stores the registry of reminders
  def self.reminders_registry
    @reminders_registry ||= ReminderRegistry.new
  end

  # Public: Stores the registry of resource spaces
  def self.resource_registry
    @resource_registry ||= ManifestRegistry.new(:resources)
  end

  # Public: Stores the registry of social shares services
  def self.social_share_services_registry
    @social_share_services_registry ||= ManifestRegistry.new(:social_share_services)
  end

  # Public: Stores the registry of notifications settings
  def self.notification_settings_registry
    @notification_settings_registry ||= ManifestRegistry.new(:notification_settings)
  end

  # Public: Stores the registry for user permissions
  def self.permissions_registry
    @permissions_registry ||= PermissionsRegistry.new
  end

  # Public: Stores the registry for authorization transfer handlers
  def self.authorization_transfer_registry
    @authorization_transfer_registry ||= BlockRegistry.new
  end

  # Public: Stores an instance of StatsRegistry
  def self.stats
    @stats ||= StatsRegistry.new
  end

  # Public: Registers configuration for a new or existing menu
  #
  # name   - A string or symbol with the name of the menu
  # &block - A block using the DSL defined in `Decidim::MenuItem`
  #
  def self.menu(name, &)
    MenuRegistry.register(name.to_sym, &)
  end

  def self.icons
    @icons ||= Decidim::IconRegistry.new
  end

  def self.admin_filter(name, &)
    AdminFiltersRegistry.register(name.to_sym, &)
  end

  # Public: Stores an instance of ViewHooks
  def self.view_hooks
    @view_hooks ||= ViewHooks.new
  end

  # Public: Stores an instance of ContentBlockRegistry
  def self.content_blocks
    @content_blocks ||= ContentBlockRegistry.new
  end

  # Public: Stores an instance of Traceability
  def self.traceability
    @traceability ||= Traceability.new
  end

  # Public: Returns the correct settings object for the given organization or
  # the default settings object when the organization cannot be determined. The
  # model to be passed to this method can be any model that responds to the
  # `organization` method or the organization itself. If the given model is not
  # an organization or does not respond to the organization method, returns the
  # default organization settings.
  #
  # model - The target model for which to fetch the settings object, either an
  #         organization or a model responding to the `organization` method.
  #
  def self.organization_settings(model)
    organization = if model.is_a?(Decidim::Organization)
                     model
                   elsif model.respond_to?(:organization) && model.organization.present?
                     model.organization
                   end

    return Decidim::OrganizationSettings.defaults unless organization

    Decidim::OrganizationSettings.for(organization)
  end

  # Defines the time after which the machine translation job should be enabled.
  # In some cases, like when Workers is processing faster than ActiveRecord can commit to Database,
  # it is required to have a delay, to prevent any discarding with
  # Decidim::MachineTranslationResourceJob due to a ActiveJob::DeserializationError.
  # In some Decidim Installations, ActiveJob can be configured to discard jobs failing with
  # ActiveJob::DeserializationError
  config_accessor :machine_translation_delay do
    0.seconds
  end

  # The etiquette validator is applied to the create and edit forms of Proposals, Meetings,
  # and Debates for both regular and admin users.
  config_accessor :enable_etiquette_validator do
    true
  end

  def self.machine_translation_service_klass
    return unless Decidim.enable_machine_translations

    Decidim.machine_translation_service.to_s.safe_constantize
  end

  def self.register_assets_path(path)
    Rails.autoloaders.main.ignore(path)
  end

  # Checks if a particular decidim gem is installed and needed by this
  # particular instance. Preferably this happens through bundler by inspecting
  # the Gemfile of the instance but when Decidim is used without bundler, this
  # will check:
  # 1. If the gem is globally available or not in the loaded specs, i.e. the
  #    gems available in the gem install directory/directories.
  # 2. If the gem has been required through `require "decidim/foo"`.
  #
  # Using bundler is suggested as it will provide more accurate results
  # regarding what is actually needed. It will resolve all the gems listed in
  # the Gemfile and also their dependencies which provides us accurate
  # information whether a gem is needed by the instance or not.
  #
  # Note that using something like defined?(Decidim::Foo) will not work because
  # the way the Decidim handles version definitions for each gem. After the gems
  # are loaded, this would always return true because the version definition
  # files of each module define that module which means it is available at
  # runtime if the gem is installed in the gem load path. In some situations it
  # can be installed there through other projects or through the command line
  # even if the instance does not require that module or even through
  # installing gems from git sources or from file paths.
  #
  # When a gem is reported as "needed" by the dependency resolver, this will
  # also require that module ensuring its availability for the initialization
  # code.
  #
  # @param mod [Symbol, String] The module name to check, e.g. `:proposals`.
  # @return [Boolean] A boolean indicating whether the module is installed.
  def self.module_installed?(mod)
    return false unless Decidim::DependencyResolver.instance.needed?("decidim-#{mod}")

    # The dependency may not be automatically loaded through the Gemfile if the
    # user lists e.g. "decidim-core" and "decidim-budgets" in it. In this
    # situation, "decidim-comments" is also needed because it is a dependency
    # for "decidim-budgets".
    require "decidim/#{mod}"

    true
  rescue LoadError
    false
  end

  def self.deprecator(gem_name: "decidim-core", deprecation_horizon: "0.32")
    @deprecator ||= ActiveSupport::Deprecation.new(deprecation_horizon, gem_name)
  end
end
