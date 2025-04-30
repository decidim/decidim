# frozen_string_literal: true

# most of this configurations can be handled through the environment variables.
# Please refer to: https://docs.decidim.org/en/develop/configure/environment_variables

Decidim.configure do |config|
  # The name of the application
  # config.application_name = Decidim::Env.new("DECIDIM_APPLICATION_NAME", "My Application Name").to_s

  # The email that will be used as sender in all emails from Decidim
  # config.mailer_sender = Decidim::Env.new("DECIDIM_MAILER_SENDER", "change-me@example.org").to_s

  # Sets the list of available locales for the whole application.
  #
  # When an organization is created through the System area, system admins will
  # be able to choose the available languages for that organization. That list
  # of languages will be equal or a subset of the list in this file.
  config.available_locales = (Decidim::Env.new("DECIDIM_AVAILABLE_LOCALES").presence || [:ca, :cs, :de, :en, :es, :eu, :fi, :fr, :it, :ja, :nl, :pl, :pt, :ro]).to_a

  # Or block set it up manually and prevent ENV manipulation:
  # config.available_locales = %w(en ca es)

  # Sets the default locale for new organizations. When creating a new
  # organization from the System area, system admins will be able to overwrite
  # this value for that specific organization.
  # config.default_locale = Decidim::Env.new("DECIDIM_DEFAULT_LOCALE", "en").to_s

  # Restrict access to the system part with an authorized ip list.
  # You can use a single ip like ("1.2.3.4"), or an ip subnet like ("1.2.3.4/24")
  # You may specify multiple ip in an array ["1.2.3.4", "1.2.3.4/24"]
  # config.system_accesslist_ips = Decidim::Env.new("DECIDIM_SYSTEM_ACCESSLIST_IPS").to_array

  # Defines a list of custom content processors. They are used to parse and
  # render specific tags inside some user-provided content. Check the docs for
  # more info.
  # config.content_processors = []

  # Whether SSL should be enabled or not.
  # if this var is not defined, it is decided automatically per-rails-environment

  # Decidim::Env.new("DECIDIM_FORCE_SSL", "auto").default_or_present_if_exists
  # config.force_ssl = Decidim::Env.new("DECIDIM_FORCE_SSL").present? unless Decidim::Env.new("DECIDIM_FORCE_SSL", "auto").default_or_present_if_exists.to_s == "auto"
  # or set it up manually and prevent any ENV manipulation:
  # config.force_ssl = true

  # Enable the service worker. By default is disabled in development and enabled in the rest of environments
  # config.service_worker_enabled = Decidim::Env.new("DECIDIM_SERVICE_WORKER_ENABLED", Rails.env.exclude?("development")).present?

  # Sets the list of static pages' slugs that can include content blocks.
  # By default is only enabled in the terms-of-service static page to allow a summary to be added and include
  # sections with a two-pane view
  # config.page_blocks = Decidim::Env.new("DECIDIM_PAGE_BLOCKS", "terms-of-service").to_array

  # CDN host configuration
  # config.storage_cdn_host = Decidim::Env.new("STORAGE_CDN_HOST", nil).to_s
  #
  # Which storage provider is going to be used for the application, provides support for the most popular options.
  # config.storage_provider = Decidim::Env.new("STORAGE_PROVIDER", "local").to_s

  # VAPID public key that will be used to sign the Push API requests.
  # config.vapid_public_key = Decidim::Env.new("VAPID_PUBLIC_KEY", nil)
  #
  # VAPID private key that will be used to sign the Push API requests.
  # config.vapid_private_key = Decidim::Env.new("VAPID_PRIVATE_KEY", nil)

  # Map and Geocoder configuration
  #
  # See Decidim docs at https://docs.decidim.org/en/develop/services/maps.html
  # for more information about how it works and how to set it up.
  #
  # == HERE Maps ==
  # config.maps = {
  #   provider: :here,
  #   api_key: ENV["MAPS_API_KEY"],
  #   static: { url: "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" }
  # }
  #
  # == OpenStreetMap (OSM) services ==
  # To use the OSM map service providers, you will need a service provider for
  # the following map servers or host all of them yourself:
  # - A tile server for the dynamic maps
  #   (https://wiki.openstreetmap.org/wiki/Tile_servers)
  # - A Nominatim geocoding server for the geocoding functionality
  #   (https://wiki.openstreetmap.org/wiki/Nominatim)
  # - A static map server for static map images
  #   (https://github.com/jperelli/osm-static-maps)
  #
  # When used, please read carefully the terms of service for your service
  # provider.
  #
  # config.maps = {
  #   provider: :osm,
  #   api_key: ENV["MAPS_API_KEY"],
  #   dynamic: {
  #     tile_layer: {
  #       url: "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
  #       api_key: true,
  #       foo: "bar=baz",
  #       attribution: %(
  #         <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors
  #       ).strip
  #       # Translatable attribution:
  #       # attribution: -> { I18n.t("tile_layer_attribution") }
  #     }
  #   },
  #   static: { url: "https://staticmap.example.org/" },
  #   geocoding: { host: "nominatim.example.org", use_https: true }
  # }
  #
  # == Combination (OpenStreetMap default + HERE Maps dynamic map tiles) ==
  # config.maps = {
  #   provider: :osm,
  #   api_key: ENV["MAPS_API_KEY"],
  #   dynamic: {
  #     provider: :here,
  #     api_key: ENV["MAPS_DYNAMIC_API_KEY"]
  #   },
  #   static: { url: "https://staticmap.example.org/" },
  #   geocoding: { host: "nominatim.example.org", use_https: true }
  # }

  # Geocoder configurations if you want to customize the default geocoding
  # settings. The maps configuration will manage which geocoding service to use,
  # so that does not need any additional configuration here. Use this only for
  # the global geocoder preferences.
  # config.geocoder = {
  #   # geocoding service request timeout, in seconds (default 3):
  #   timeout: 5,
  #   # set default units to kilometers:
  #   units: :km,
  #   # caching (see https://github.com/alexreisner/geocoder#caching for details):
  #   cache: Redis.new,
  #   cache_prefix: "..."
  # }
  if Decidim::Env.new("MAPS_STATIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).present?
    static_provider = Decidim::Env.new("MAPS_STATIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).to_s
    dynamic_provider = Decidim::Env.new("MAPS_DYNAMIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).to_s
    dynamic_url = ENV.fetch("MAPS_DYNAMIC_URL", nil)
    static_url = ENV.fetch("MAPS_STATIC_URL", nil)
    static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here"
    config.maps = {
      provider: static_provider,
      api_key: Decidim::Env.new("MAPS_STATIC_API_KEY", ENV.fetch("MAPS_API_KEY", nil)).to_s,
      static: { url: static_url },
      dynamic: {
        provider: dynamic_provider,
        api_key: Decidim::Env.new("MAPS_DYNAMIC_API_KEY", ENV.fetch("MAPS_API_KEY", nil)).to_s
      }
    }
    config.maps[:geocoding] = { host: ENV["MAPS_GEOCODING_HOST"], use_https: true } if ENV["MAPS_GEOCODING_HOST"]
    config.maps[:dynamic][:tile_layer] = {}
    config.maps[:dynamic][:tile_layer][:url] = dynamic_url if dynamic_url
    config.maps[:dynamic][:tile_layer][:attribution] = ENV["MAPS_ATTRIBUTION"] if ENV["MAPS_ATTRIBUTION"]
    if ENV["MAPS_EXTRA_VARS"].present?
      vars = URI.decode_www_form(ENV["MAPS_EXTRA_VARS"])
      vars.each do |key, value|
        # perform a naive type conversion
        config.maps[:dynamic][:tile_layer][key] = case value
                                                  when /^true$|^false$/i
                                                    value.downcase == "true"
                                                  when /\A[-+]?\d+\z/
                                                    value.to_i
                                                  else
                                                    value
                                                  end
      end
    end
  end

  # Custom resource reference generator method. Check the docs for more info.
  # config.reference_generator = lambda do |resource, component|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = Decidim::Env.new("DECIDIM_CURRENCY_UNIT", "€").to_s

  # Workaround to enable SVG assets cors
  # config.cors_enabled = Decidim::Env.new("DECIDIM_CORS_ENABLED", "false").present?

  # Defines the quality of image uploads after processing. Image uploads are
  # processed by Decidim, this value helps reduce the size of the files.
  # config.image_uploader_quality = Decidim::Env.new("DECIDIM_IMAGE_UPLOADER_QUALITY", "80").to_i

  # config.maximum_attachment_size = Decidim::Env.new("DECIDIM_MAXIMUM_ATTACHMENT_SIZE", "10").to_i
  # config.maximum_avatar_size = Decidim::Env.new("DECIDIM_MAXIMUM_AVATAR_SIZE", "5").to_i

  # The number of reports which a resource can receive before hiding it
  # config.max_reports_before_hiding = Decidim::Env.new("DECIDIM_MAX_REPORTS_BEFORE_HIDING", "3").to_i

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This component also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  # config.enable_html_header_snippets = Decidim::Env.new("DECIDIM_ENABLE_HTML_HEADER_SNIPPETS").present?

  # Allow organizations admins to track newsletter links.
  # unless Decidim::Env.new("DECIDIM_TRACK_NEWSLETTER_LINKS", "auto").default_or_present_if_exists.to_s == "auto"
  #   config.track_newsletter_links = Decidim::Env.new("DECIDIM_FORCE_SSL", "auto").default_or_present_if_exists
  # end

  # Amount of time that the download your data files will be available in the server.
  # config.download_your_data_expiry_time = Decidim::Env.new("DECIDIM_DOWNLOAD_YOUR_DATA_EXPIRY_TIME", "7").to_i.days

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  # config.throttling_max_requests = Decidim::Env.new("DECIDIM_THROTTLING_MAX_REQUESTS", "100").to_i

  # Time window in which the throttling is applied.
  # config.throttling_period = Decidim::Env.new("DECIDIM_THROTTLING_PERIOD", "1").to_i.minutes

  # Time window were users can access the website even if their email is not confirmed.
  # config.unconfirmed_access_for = Decidim::Env.new("DECIDIM_UNCONFIRMED_ACCESS_FOR", "0").to_i.days

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  #
  # If not set, it will be ignored.
  # config.base_uploads_path = Decidim::Env.new("DECIDIM_BASE_UPLOADS_PATH").to_s if Decidim::Env.new("DECIDIM_BASE_UPLOADS_PATH").present?

  # SMS gateway configuration
  #
  # If you want to verify your users by sending a verification code via
  # SMS you need to provide a SMS gateway service class.
  #
  # An example class would be something like:
  #
  # class MySMSGatewayService
  #   attr_reader :mobile_phone_number, :code
  #
  #   def initialize(mobile_phone_number, code)
  #     @mobile_phone_number = mobile_phone_number
  #     @code = code
  #   end
  #
  #   def deliver_code
  #     # Actual code to deliver the code
  #     true
  #   end
  # end
  #
  # config.sms_gateway_service = "MySMSGatewayService"

  # Timestamp service configuration
  #
  # Provide a class to generate a timestamp for a document. The instances of
  # this class are initialized with a hash containing the :document key with
  # the document to be timestamped as value. The instances respond to a
  # timestamp public method with the timestamp
  #
  # An example class would be something like:
  #
  # class MyTimestampService
  #   attr_accessor :document
  #
  #   def initialize(args = {})
  #     @document = args.fetch(:document)
  #   end
  #
  #   def timestamp
  #     # Code to generate timestamp
  #     "My timestamp"
  #   end
  # end
  #
  #
  # config.timestamp_service = "MyTimestampService"

  # PDF signature service configuration
  #
  # Provide a class to process a pdf and return the document including a
  # digital signature. The instances of this class are initialized with a hash
  # containing the :pdf key with the pdf file content as value. The instances
  # respond to a signed_pdf method containing the pdf with the signature
  #
  # An example class would be something like:
  #
  # class MyPDFSignatureService
  #   attr_accessor :pdf
  #
  #   def initialize(args = {})
  #     @pdf = args.fetch(:pdf)
  #   end
  #
  #   def signed_pdf
  #     # Code to return the pdf signed
  #   end
  # end
  #
  # config.pdf_signature_service = "MyPDFSignatureService"

  # Etherpad configuration
  #
  # Only needed if you want to have Etherpad integration with Decidim. See
  # Decidim docs at https://docs.decidim.org/en/services/etherpad/ in order to set it up.
  #
  if Decidim::Env.new("ETHERPAD_SERVER").present? && Decidim::Env.new("ETHERPAD_API_KEY").present?
    config.etherpad = {
      server: Decidim::Env.new("ETHERPAD_SERVER").to_s,
      api_key: Decidim::Env.new("ETHERPAD_API_KEY").to_s,
      api_version: Decidim::Env.new("ETHERPAD_API_VERSION", "1.2.1").to_s
    }
  end

  # Sets Decidim::Exporters::CSV's default column separator
  # config.default_csv_col_sep = Decidim::Env.new("DECIDIM_DEFAULT_CSV_COL_SEP", ";").to_s

  # The list of roles a user can have, not considering the space-specific roles.
  # config.user_roles = %w(admin user_manager)

  # The list of visibility options for amendments. An Array of Strings that
  # serve both as locale keys and values to construct the input collection in
  # Decidim::Amendment::VisibilityStepSetting::options.
  #
  # This collection is used in Decidim::Admin::SettingsHelper to generate a
  # radio buttons collection input field form for a Decidim::Component
  # step setting :amendments_visibility.
  # config.amendments_visibility_options = %w(all participants)

  # Machine Translation Configuration
  #
  # See Decidim docs at https://docs.decidim.org/en/develop/machine_translations/
  # for more information about how it works and how to set it up.
  #
  # Enable machine translations
  config.enable_machine_translations = false
  #
  # If you want to enable machine translation you can create your own service
  # to interact with third party service to translate the user content.
  #
  # If you still want to use "Decidim::Dev::DummyTranslator" as translator placeholder,
  # add the following line at the beginning of this file:
  # require "decidim/dev/dummy_translator"
  #
  # An example class would be something like:
  #
  # class MyTranslationService
  #   attr_reader :text, :original_locale, :target_locale
  #
  #   def initialize(text, original_locale, target_locale)
  #     @text = text
  #     @original_locale = original_locale
  #     @target_locale = target_locale
  #   end
  #
  #   def translate
  #     # Actual code to translate the text
  #   end
  # end
  #
  # config.machine_translation_service = "MyTranslationService"

  # Defines the social networking services used for social sharing
  # config.social_share_services = Decidim::Env.new("DECIDIM_SOCIAL_SHARE_SERVICES", "X, Facebook, WhatsApp, Telegram").to_array

  # Defines the name of the cookie used to check if the user allows Decidim to
  # set cookies.
  # config.consent_cookie_name = Decidim::Env.new("DECIDIM_CONSENT_COOKIE_NAME", "decidim-consent").to_s

  # Defines data consent categories and the data stored in each category.
  # config.consent_categories = [
  #   {
  #     slug: "essential",
  #     mandatory: true,
  #     items: [
  #       {
  #         type: "cookie",
  #         name: "_session_id"
  #       },
  #       {
  #         type: "cookie",
  #         name: Decidim.consent_cookie_name
  #       }
  #     ]
  #   },
  #   {
  #     slug: "preferences",
  #     mandatory: false
  #   },
  #   {
  #     slug: "analytics",
  #     mandatory: false
  #   },
  #   {
  #     slug: "marketing",
  #     mandatory: false
  #   }
  # ]

  # Defines additional content security policies following the structure
  # Read more: https://docs.decidim.org/en/develop/configure/initializer#_content_security_policy
  config.content_security_policies_extra = {}

  # Admin admin password configurations
  # config.admin_password_strong = Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_STRONG", true).present?

  # config.admin_password_expiration_days = Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS", 90).to_i
  # config.admin_password_min_length = Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_MIN_LENGTH", 15).to_i
  # config.admin_password_repetition_times = Decidim::Env.new("DECIDIM_ADMIN_PASSWORD_REPETITION_TIMES", 5).to_i

  # Delete inactive users configuration
  # config.delete_inactive_users_after_days = Decidim::Env.new("DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS", 365).to_i
  # config.minimum_inactivity_period = Decidim::Env.new("DECIDIM_MINIMUM_INACTIVITY_PERIOD", 30).to_i
  # config.delete_inactive_users_first_warning_days_before = Decidim::Env.new("DECIDIM_DELETE_INACTIVE_USERS_FIRST_WARNING_DAYS_BEFORE", 30).to_i
  # config.delete_inactive_users_last_warning_days_before = Decidim::Env.new("DECIDIM_DELETE_INACTIVE_USERS_LAST_WARNING_DAYS_BEFORE", 7).to_i

  # Additional optional configurations (see decidim-core/lib/decidim/core.rb)
  # config.cache_key_separator = Decidim::Env.new("DECIDIM_CACHE_KEY_SEPARATOR", "/").to_s
  # config.cache_expiry_time = Decidim::Env.new("DECIDIM_CACHE_EXPIRATION_TIME", "1440").to_i.minutes
  # config.stats_cache_expiry_time = Decidim::Env.new("DECIDIM_STATS_CACHE_EXPIRATION_TIME", 10).to_i.minutes
  # config.expire_session_after = Decidim::Env.new("DECIDIM_EXPIRE_SESSION_AFTER", "30").to_i.minutes
  # unless Decidim::Env.new("DECIDIM_ENABLE_REMEMBER_ME", "auto").default_or_present_if_exists.to_s == "auto"
  #   config.enable_remember_me = Decidim::Env.new("DECIDIM_ENABLE_REMEMBER_ME", "auto").default_or_present_if_exists
  # end

  # config.session_timeout_interval = Decidim::Env.new("DECIDIM_SESSION_TIMEOUT_INTERVAL", "10").to_i.seconds
  # config.follow_http_x_forwarded_host = Decidim::Env.new("DECIDIM_FOLLOW_HTTP_X_FORWARDED_HOST").present?
  # config.maximum_conversation_message_length = Decidim::Env.new("DECIDIM_MAXIMUM_CONVERSATION_MESSAGE_LENGTH", "1000").to_i
  # config.password_similarity_length = Decidim::Env.new("DECIDIM_PASSWORD_SIMILARITY_LENGTH", 4).to_i
  # config.denied_passwords = Decidim::Env.new("DECIDIM_DENIED_PASSWORDS").to_array(separator: ", ")
  # config.allow_open_redirects = Decidim::Env.new("DECIDIM_ALLOW_OPEN_REDIRECTS").present?
  # config.enable_etiquette_validator = Decidim::Env.new("DECIDIM_ENABLE_ETIQUETTE_VALIDATOR", true).present?
end

# if Decidim.module_installed? :api
#   Decidim::Api.configure do |config|
#     config.schema_max_per_page = Decidim::Env.new("API_SCHEMA_MAX_PER_PAGE", 50).to_i
#     config.schema_max_complexity = Decidim::Env.new("API_SCHEMA_MAX_COMPLEXITY", 5000).to_i
#     config.schema_max_depth = Decidim::Env.new("API_SCHEMA_MAX_DEPTH", 15).to_i
#     config.disclose_system_version = Decidim::Env.new("DECIDIM_API_DISCLOSE_SYSTEM_VERSION").present?
#     config.force_api_authentication = Decidim::Env.new("DECIDIM_API_FORCE_API_AUTHENTICATION").present?
#   end
# end

# if Decidim.module_installed? :proposals
#   Decidim::Proposals.configure do |config|
#     config.participatory_space_highlighted_proposals_limit = Decidim::Env.new("PROPOSALS_PARTICIPATORY_SPACE_HIGHLIGHTED_PROPOSALS_LIMIT", 4).to_i
#     config.process_group_highlighted_proposals_limit = Decidim::Env.new("PROPOSALS_PROCESS_GROUP_HIGHLIGHTED_PROPOSALS_LIMIT", 3).to_i
#   end
# end

# if Decidim.module_installed? :meetings
#   Decidim::Meetings.configure do |config|
#     config.upcoming_meeting_notification = Decidim::Env.new("MEETINGS_UPCOMING_MEETING_NOTIFICATION", 2).to_i.days
#     if Decidim::Env.new("MEETINGS_EMBEDDABLE_SERVICES").to_array(separator: " ").present?
#       config.embeddable_services = Decidim::Env.new("MEETINGS_EMBEDDABLE_SERVICES").to_array(separator: " ")
#     end
#     unless Decidim::Env.new("MEETINGS_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists.to_s == "auto"
#       config.enable_proposal_linking = Decidim::Env.new("MEETINGS_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists
#     end
#   end
# end

# if Decidim.module_installed? :budgets
#   Decidim::Budgets.configure do |config|
#     unless Decidim::Env.new("BUDGETS_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists.to_s == "auto"
#       config.enable_proposal_linking = Decidim::Env.new("BUDGETS_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists
#     end
#   end
# end

# if Decidim.module_installed? :accountability
#   Decidim::Accountability.configure do |config|
#     unless Decidim::Env.new("ACCOUNTABILITY_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists.to_s == "auto"
#       config.enable_proposal_linking = Decidim::Env.new("ACCOUNTABILITY_ENABLE_PROPOSAL_LINKING", "auto").default_or_present_if_exists
#     end
#   end
# end

# if Decidim.module_installed? :initiatives
#   Decidim::Initiatives.configure do |config|
#     unless Decidim::Env.new("INITIATIVES_CREATION_ENABLED", "auto").default_or_present_if_exists.to_s == "auto"
#       config.creation_enabled = Decidim::Env.new("INITIATIVES_CREATION_ENABLED", "auto").default_or_present_if_exists
#     end
#     config.minimum_committee_members = Decidim::Env.new("INITIATIVES_MINIMUM_COMMITTEE_MEMBERS", 2).to_i
#     config.default_signature_time_period_length = Decidim::Env.new("INITIATIVES_DEFAULT_SIGNATURE_TIME_PERIOD_LENGTH", 120).to_i
#     config.default_components = Decidim::Env.new("INITIATIVES_DEFAULT_COMPONENTS", "pages, meetings").to_array
#     config.first_notification_percentage = Decidim::Env.new("INITIATIVES_FIRST_NOTIFICATION_PERCENTAGE", 33).to_i
#     config.second_notification_percentage = Decidim::Env.new("INITIATIVES_SECOND_NOTIFICATION_PERCENTAGE", 66).to_i
#     config.stats_cache_expiration_time = Decidim::Env.new("INITIATIVES_STATS_CACHE_EXPIRATION_TIME", 5).to_i.minutes
#     config.max_time_in_validating_state = Decidim::Env.new("INITIATIVES_MAX_TIME_IN_VALIDATING_STATE", 60).to_i.days
#     unless Decidim::Env.new("INITIATIVES_PRINT_ENABLED", "auto").default_or_present_if_exists.to_s == "auto"
#       config.print_enabled = Decidim::Env.new("INITIATIVES_PRINT_ENABLED", "auto").present?
#     end
#     config.do_not_require_authorization = Decidim::Env.new("INITIATIVES_DO_NOT_REQUIRE_AUTHORIZATION").present?
#     if Decidim::Env.new("INITIATIVES_SIGNATURE_HANDLER_ENCRYPTION_SECRET").present?
#       config.signature_handler_encryption_secret = Decidim::Env.new("INITIATIVES_SIGNATURE_HANDLER_ENCRYPTION_SECRET")
#     end
#   end
# end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

# Inform Decidim about the assets folder
Decidim.register_assets_path File.expand_path("app/packs", Rails.application.root)
