# frozen_string_literal: true

Decidim.configure do |config|
  # The name of the application
  config.application_name = Rails.application.credentials.decidim[:application_name]

  # The email that will be used as sender in all emails from Decidim
  config.mailer_sender = Rails.application.credentials.decidim[:mailer_sender]

  # Sets the list of available locales for the whole application.
  #
  # When an organization is created through the System area, system admins will
  # be able to choose the available languages for that organization. That list
  # of languages will be equal or a subset of the list in this file.
  config.available_locales = Rails.application.credentials.decidim[:available_locales].presence || [:en]
  # Or block set it up manually and prevent ENV manipulation:
  # config.available_locales = %w(en ca es)

  # Sets the default locale for new organizations. When creating a new
  # organization from the System area, system admins will be able to overwrite
  # this value for that specific organization.
  config.default_locale = Rails.application.credentials.decidim[:default_locale].presence || :en

  # Restrict access to the system part with an authorized ip list.
  # You can use a single ip like ("1.2.3.4"), or an ip subnet like ("1.2.3.4/24")
  # You may specify multiple ip in an array ["1.2.3.4", "1.2.3.4/24"]
  config.system_accesslist_ips = Rails.application.credentials.decidim[:system_accesslist_ips] if Rails.application.credentials.decidim[:system_accesslist_ips].present?

  # Defines a list of custom content processors. They are used to parse and
  # render specific tags inside some user-provided content. Check the docs for
  # more info.
  # config.content_processors = []

  # Whether SSL should be enabled or not.
  # if this var is not defined, it is decided automatically per-rails-environment
  config.force_ssl = Rails.application.credentials.decidim[:force_ssl].present? unless Rails.application.credentials.decidim[:force_ssl] == "auto"
  # or set it up manually and prevent any ENV manipulation:
  # config.force_ssl = true

  # Enable the service worker. By default is disabled in development and enabled in the rest of environments
  config.service_worker_enabled = Rails.application.credentials.decidim[:service_worker_enabled].present?

  # Sets the list of static pages' slugs that can include content blocks.
  # By default is only enabled in the terms-of-service static page to allow a summary to be added and include
  # sections with a two-pane view
  config.page_blocks = Rails.application.credentials.decidim[:page_blocks].presence || %w(terms-of-service)

  # Map and Geocoder configuration
  #
  # See Decidim docs at https://docs.decidim.org/en/develop/services/maps.html
  # for more information about how it works and how to set it up.
  #
  # == HERE Maps ==
  # config.maps = {
  #   provider: :here,
  #   api_key: Rails.application.credentials.maps[:api_key],
  #   static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
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
  #   api_key: Rails.application.credentials.maps[:api_key],
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
  #   api_key: Rails.application.credentials.maps[:api_key],
  #   dynamic: {
  #     provider: :here,
  #     api_key: Rails.application.credentials.maps[:here_api_key]
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
  if Rails.application.credentials.maps.present? && Rails.application.credentials.maps[:static_provider].present?
    static_provider = Rails.application.credentials.maps[:static_provider]
    dynamic_provider = Rails.application.credentials.maps[:dynamic_provider]
    dynamic_url = Rails.application.credentials.maps[:dynamic_url]
    static_url = Rails.application.credentials.maps[:static_url]
    static_url = "https://image.maps.ls.hereapi.com/mia/1.6/mapview" if static_provider == "here" && static_url.blank?
    config.maps = {
      provider: static_provider,
      api_key: Rails.application.credentials.maps[:static_api_key],
      static: { url: static_url },
      dynamic: {
        provider: dynamic_provider,
        api_key: Rails.application.credentials.maps[:dynamic_api_key]
      }
    }
    config.maps[:geocoding] = { host: Rails.application.credentials.maps[:geocoding_host], use_https: true } if Rails.application.credentials.maps[:geocoding_host]
    config.maps[:dynamic][:tile_layer] = {}
    config.maps[:dynamic][:tile_layer][:url] = dynamic_url if dynamic_url
    config.maps[:dynamic][:tile_layer][:attribution] = Rails.application.credentials.maps[:attribution] if Rails.application.credentials.maps[:attribution]
    if Rails.application.credentials.maps[:extra_vars].present?
      vars = URI.decode_www_form(Rails.application.credentials.maps[:extra_vars])
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
  config.currency_unit = Rails.application.credentials.decidim[:currency_unit] if Rails.application.credentials.decidim[:currency_unit].present?

  # Workaround to enable SVG assets cors
  config.cors_enabled = Rails.application.credentials.decidim[:cors_enabled].present?

  # Defines the quality of image uploads after processing. Image uploads are
  # processed by Decidim, this value helps reduce the size of the files.
  config.image_uploader_quality = Rails.application.credentials.decidim[:image_uploader_quality].to_i

  config.maximum_attachment_size = Rails.application.credentials.decidim[:maximum_attachment_size].to_i.megabytes
  config.maximum_avatar_size = Rails.application.credentials.decidim[:maximum_avatar_size].to_i.megabytes

  # The number of reports which a resource can receive before hiding it
  config.max_reports_before_hiding = Rails.application.credentials.decidim[:max_reports_before_hiding].to_i

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
  config.enable_html_header_snippets = Rails.application.credentials.decidim[:enable_html_header_snippets].present?

  # Allow organizations admins to track newsletter links.
  unless Rails.application.credentials.decidim[:track_newsletter_links] == "auto"
    config.track_newsletter_links = Rails.application.credentials.decidim[:track_newsletter_links].present?
  end

  # Amount of time that the download your data files will be available in the server.
  config.download_your_data_expiry_time = Rails.application.credentials.decidim[:download_your_data_expiry_time].to_i.days

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  config.throttling_max_requests = Rails.application.credentials.decidim[:throttling_max_requests].to_i

  # Time window in which the throttling is applied.
  config.throttling_period = Rails.application.credentials.decidim[:throttling_period].to_i.minutes

  # Time window were users can access the website even if their email is not confirmed.
  config.unconfirmed_access_for = Rails.application.credentials.decidim[:unconfirmed_access_for].to_i.days

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  #
  # If not set, it will be ignored.
  config.base_uploads_path = Rails.application.credentials.decidim[:base_uploads_path] if Rails.application.credentials.decidim[:base_uploads_path].present?

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
  if Rails.application.credentials.etherpad.present? && Rails.application.credentials.etherpad[:server].present?
    config.etherpad = {
      server: Rails.application.credentials.etherpad[:server],
      api_key: Rails.application.credentials.etherpad[:api_key],
      api_version: Rails.application.credentials.etherpad[:api_version]
    }
  end

  # Sets Decidim::Exporters::CSV's default column separator
  config.default_csv_col_sep = Rails.application.credentials.decidim[:default_csv_col_sep] if Rails.application.credentials.decidim[:default_csv_col_sep].present?

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
  config.social_share_services = Rails.application.credentials.decidim[:social_share_services]

  # Defines the name of the cookie used to check if the user allows Decidim to
  # set cookies.
  config.consent_cookie_name = Rails.application.credentials.decidim[:consent_cookie_name] if Rails.application.credentials.decidim[:consent_cookie_name].present?

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
  Rails.application.credentials.dig(:decidim, :admin_password, :strong).tap do |strong_pw|
    # When the strong password is not configured, default to true
    config.admin_password_strong = strong_pw.nil? ? true : strong_pw.present?
  end
  config.admin_password_expiration_days = Rails.application.credentials.dig(:decidim, :admin_password, :expiration_days).presence || 90
  config.admin_password_min_length = Rails.application.credentials.dig(:decidim, :admin_password, :min_length).presence || 15
  config.admin_password_repetition_times = Rails.application.credentials.dig(:decidim, :admin_password, :repetition_times).presence || 5

  # Additional optional configurations (see decidim-core/lib/decidim/core.rb)
  config.cache_key_separator = Rails.application.credentials.decidim[:cache_key_separator] if Rails.application.credentials.decidim[:cache_key_separator].present?
  config.expire_session_after = Rails.application.credentials.decidim[:expire_session_after].to_i.minutes if Rails.application.credentials.decidim[:expire_session_after].present?
  config.enable_remember_me = Rails.application.credentials.decidim[:enable_remember_me].present? unless Rails.application.credentials.decidim[:enable_remember_me] == "auto"
  if Rails.application.credentials.decidim[:session_timeout_interval].present?
    config.session_timeout_interval = Rails.application.credentials.decidim[:session_timeout_interval].to_i.seconds
  end
  config.follow_http_x_forwarded_host = Rails.application.credentials.decidim[:follow_http_x_forwarded_host].present?
  config.maximum_conversation_message_length = Rails.application.credentials.decidim[:maximum_conversation_message_length].to_i
  if Rails.application.credentials.decidim[:password_similarity_length].present?
    config.password_similarity_length = Rails.application.credentials.decidim[:password_similarity_length]
  end
  config.denied_passwords = Rails.application.credentials.decidim[:denied_passwords] if Rails.application.credentials.decidim[:denied_passwords].present?
  config.allow_open_redirects = Rails.application.credentials.decidim[:allow_open_redirects] if Rails.application.credentials.decidim[:allow_open_redirects].present?
end

if Decidim.module_installed? :api
  Decidim::Api.configure do |config|
    config.schema_max_per_page = Rails.application.credentials.dig(:decidim, :api, :schema_max_per_page).presence || 50
    config.schema_max_complexity = Rails.application.credentials.dig(:decidim, :api, :schema_max_complexity).presence || 5000
    config.schema_max_depth = Rails.application.credentials.dig(:decidim, :api, :schema_max_depth).presence || 15
  end
end

if Decidim.module_installed? :proposals
  Decidim::Proposals.configure do |config|
    config.participatory_space_highlighted_proposals_limit = Rails.application.credentials.dig(:decidim, :proposals, :participatory_space_highlighted_proposals_limit).presence || 4
    config.process_group_highlighted_proposals_limit = Rails.application.credentials.dig(:decidim, :proposals, :process_group_highlighted_proposals_limit).presence || 3
  end
end

if Decidim.module_installed? :meetings
  Decidim::Meetings.configure do |config|
    config.upcoming_meeting_notification = Rails.application.credentials.dig(:decidim, :meetings, :upcoming_meeting_notification).to_i.days
    if Rails.application.credentials.dig(:decidim, :meetings, :embeddable_services).present?
      config.embeddable_services = Rails.application.credentials.dig(:decidim, :meetings, :embeddable_services)
    end
    unless Rails.application.credentials.dig(:decidim, :meetings, :enable_proposal_linking) == "auto"
      config.enable_proposal_linking = Rails.application.credentials.dig(:decidim, :meetings, :enable_proposal_linking).present?
    end
  end
end

if Decidim.module_installed? :budgets
  Decidim::Budgets.configure do |config|
    unless Rails.application.credentials.dig(:decidim, :budgets, :enable_proposal_linking) == "auto"
      config.enable_proposal_linking = Rails.application.credentials.dig(:decidim, :budgets, :enable_proposal_linking).present?
    end
  end
end

if Decidim.module_installed? :accountability
  Decidim::Accountability.configure do |config|
    unless Rails.application.credentials.dig(:decidim, :accountability, :enable_proposal_linking) == "auto"
      config.enable_proposal_linking = Rails.application.credentials.dig(:decidim, :accountability, :enable_proposal_linking).present?
    end
  end
end

if Decidim.module_installed? :initiatives
  Decidim::Initiatives.configure do |config|
    unless Rails.application.credentials.dig(:decidim, :initiatives, :creation_enabled) == "auto"
      config.creation_enabled = Rails.application.credentials.dig(:decidim, :initiatives, :creation_enabled).present?
    end
    config.minimum_committee_members = Rails.application.credentials.dig(:decidim, :initiatives, :minimum_committee_members).presence || 2
    config.default_signature_time_period_length = Rails.application.credentials.dig(:decidim, :initiatives, :default_signature_time_period_length).presence || 120
    config.default_components = Rails.application.credentials.dig(:decidim, :initiatives, :default_components)
    config.first_notification_percentage = Rails.application.credentials.dig(:decidim, :initiatives, :first_notification_percentage).presence || 33
    config.second_notification_percentage = Rails.application.credentials.dig(:decidim, :initiatives, :second_notification_percentage).presence || 66
    config.stats_cache_expiration_time = Rails.application.credentials.dig(:decidim, :initiatives, :stats_cache_expiration_time).to_i.minutes
    config.max_time_in_validating_state = Rails.application.credentials.dig(:decidim, :initiatives, :max_time_in_validating_state).to_i.days
    unless Rails.application.credentials.dig(:decidim, :initiatives, :print_enabled) == "auto"
      config.print_enabled = Rails.application.credentials.dig(:decidim, :initiatives, :print_enabled).present?
    end
    config.do_not_require_authorization = Rails.application.credentials.dig(:decidim, :initiatives, :do_not_require_authorization).present?
  end
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

# Inform Decidim about the assets folder
Decidim.register_assets_path File.expand_path("app/packs", Rails.application.root)
