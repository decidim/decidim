# frozen_string_literal: true

Decidim.configure do |config|
  # The name of the application
  config.application_name = "My Application Name"

  # The email that will be used as sender in all emails from Decidim
  config.mailer_sender = "change-me@example.org"

  # Sets the list of available locales for the whole application.
  #
  # When an organization is created through the System area, system admins will
  # be able to choose the available languages for that organization. That list
  # of languages will be equal or a subset of the list in this file.
  config.available_locales = [:en, :ca, :es]

  # Sets the default locale for new organizations. When creating a new
  # organization from the System area, system admins will be able to overwrite
  # this value for that specific organization.
  config.default_locale = :en

  # Restrict access to the system part with an authorized ip list.
  # You can use a single ip like ("1.2.3.4"), or an ip subnet like ("1.2.3.4/24")
  # You may specify multiple ip in an array ["1.2.3.4", "1.2.3.4/24"]
  # config.system_accesslist_ips = ["127.0.0.1"]

  # Defines a list of custom content processors. They are used to parse and
  # render specific tags inside some user-provided content. Check the docs for
  # more info.
  # config.content_processors = []

  # Whether SSL should be enabled or not.
  # config.force_ssl = true

  # Map and Geocoder configuration
  #
  # == HERE Maps ==
  # config.maps = {
  #   provider: :here,
  #   api_key: Rails.application.secrets.maps[:api_key],
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
  #   api_key: Rails.application.secrets.maps[:api_key],
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
  #   api_key: Rails.application.secrets.maps[:api_key],
  #   dynamic: {
  #     provider: :here,
  #     api_key: Rails.application.secrets.maps[:here_api_key]
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

  # Custom resource reference generator method. Check the docs for more info.
  # config.reference_generator = lambda do |resource, component|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = "€"

  # Defines the quality of image uploads after processing. Image uploads are
  # processed by Decidim, this value helps reduce the size of the files.
  # config.image_uploader_quality = 80

  # The number of reports which a resource can receive before hiding it
  # config.max_reports_before_hiding = 3

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
  config.enable_html_header_snippets = false

  # Allow organizations admins to track newsletter links.
  # config.track_newsletter_links = true

  # Amount of time that the data portability files will be available in the server.
  # config.data_portability_expiry_time = 7.days

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  # config.throttling_max_requests = 100

  # Time window in which the throttling is applied.
  # config.throttling_period = 1.minute

  # Time window were users can access the website even if their email is not confirmed.
  # config.unconfirmed_access_for = 2.days

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  #
  # If not set, it will be ignored.
  # config.base_uploads_path = nil

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
  # the document to be timestamped as value. The istances respond to a
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
  # Decidim docs at docs/services/etherpad.md in order to set it up.
  #
  # config.etherpad = {
  #   server: Rails.application.secrets.etherpad[:server],
  #   api_key: Rails.application.secrets.etherpad[:api_key],
  #   api_version: Rails.application.secrets.etherpad[:api_version]
  # }

  # Sets Decidim::Exporters::CSV's default column separator
  # config.default_csv_col_sep = ";"

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
  # Enable machine translations
  config.enable_machine_translations = false
  #
  # If you want to enable machine translation you can create your own service
  # to interact with third party service to translate the user content.
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

  # Defines the name of the cookie used to check if the user allows Decidim to
  # set cookies.
  # config.consent_cookie_name = "decidim-cc"
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
