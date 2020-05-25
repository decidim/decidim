# frozen_string_literal: true

require "decidim/core/engine"
require "decidim/core/api"
require "decidim/core/version"
# Decidim configuration.
module Decidim
  autoload :Deprecations, "decidim/deprecations"
  autoload :ActsAsAuthor, "decidim/acts_as_author"
  autoload :TranslatableAttributes, "decidim/translatable_attributes"
  autoload :JsonbAttributes, "decidim/jsonb_attributes"
  autoload :FormBuilder, "decidim/form_builder"
  autoload :AuthorizationFormBuilder, "decidim/authorization_form_builder"
  autoload :FilterFormBuilder, "decidim/filter_form_builder"
  autoload :ComponentManifest, "decidim/component_manifest"
  autoload :ParticipatorySpaceManifest, "decidim/participatory_space_manifest"
  autoload :ResourceManifest, "decidim/resource_manifest"
  autoload :Resourceable, "decidim/resourceable"
  autoload :Traceable, "decidim/traceable"
  autoload :Loggable, "decidim/loggable"
  autoload :Reportable, "decidim/reportable"
  autoload :Authorable, "decidim/authorable"
  autoload :Coauthorable, "decidim/coauthorable"
  autoload :Participable, "decidim/participable"
  autoload :Publicable, "decidim/publicable"
  autoload :Scopable, "decidim/scopable"
  autoload :ScopableComponent, "decidim/scopable_component"
  autoload :ContentParsers, "decidim/content_parsers"
  autoload :ContentRenderers, "decidim/content_renderers"
  autoload :ContentProcessor, "decidim/content_processor"
  autoload :Components, "decidim/components"
  autoload :HasAttachmentCollections, "decidim/has_attachment_collections"
  autoload :HasAttachments, "decidim/has_attachments"
  autoload :ComponentValidator, "decidim/component_validator"
  autoload :HasSettings, "decidim/has_settings"
  autoload :HasComponent, "decidim/has_component"
  autoload :HasCategory, "decidim/has_category"
  autoload :Followable, "decidim/followable"
  autoload :FriendlyDates, "decidim/friendly_dates"
  autoload :Nicknamizable, "decidim/nicknamizable"
  autoload :HasReference, "decidim/has_reference"
  autoload :Attributes, "decidim/attributes"
  autoload :StatsRegistry, "decidim/stats_registry"
  autoload :Exporters, "decidim/exporters"
  autoload :FileZipper, "decidim/file_zipper"
  autoload :Menu, "decidim/menu"
  autoload :MenuItem, "decidim/menu_item"
  autoload :MenuRegistry, "decidim/menu_registry"
  autoload :Messaging, "decidim/messaging"
  autoload :ManifestRegistry, "decidim/manifest_registry"
  autoload :EngineRouter, "decidim/engine_router"
  autoload :Events, "decidim/events"
  autoload :ViewHooks, "decidim/view_hooks"
  autoload :ContentBlockRegistry, "decidim/content_block_registry"
  autoload :ContentBlockManifest, "decidim/content_block_manifest"
  autoload :MetricRegistry, "decidim/metric_registry"
  autoload :MetricManifest, "decidim/metric_manifest"
  autoload :MetricOperation, "decidim/metric_operation"
  autoload :MetricOperationManifest, "decidim/metric_operation_manifest"
  autoload :AttributeEncryptor, "decidim/attribute_encryptor"
  autoload :NewsletterEncryptor, "decidim/newsletter_encryptor"
  autoload :NewsletterParticipant, "decidim/newsletter_participant"
  autoload :Searchable, "decidim/searchable"
  autoload :SearchResourceFieldsMapper, "decidim/search_resource_fields_mapper"
  autoload :QueryExtensions, "decidim/query_extensions"
  autoload :ParticipatorySpaceResourceable, "decidim/participatory_space_resourceable"
  autoload :HasPrivateUsers, "decidim/has_private_users"
  autoload :ViewModel, "decidim/view_model"
  autoload :FingerprintCalculator, "decidim/fingerprint_calculator"
  autoload :Fingerprintable, "decidim/fingerprintable"
  autoload :DataPortability, "decidim/data_portability"
  autoload :DataPortabilitySerializers, "decidim/data_portability_serializers"
  autoload :DataPortabilityExporter, "decidim/data_portability_exporter"
  autoload :Amendable, "decidim/amendable"
  autoload :Gamification, "decidim/gamification"
  autoload :Hashtag, "decidim/hashtag"
  autoload :Hashtaggable, "decidim/hashtaggable"
  autoload :Paddable, "decidim/paddable"
  autoload :OpenDataExporter, "decidim/open_data_exporter"
  autoload :IoEncoder, "decidim/io_encoder"
  autoload :HasResourcePermission, "decidim/has_resource_permission"
  autoload :PermissionsRegistry, "decidim/permissions_registry"
  autoload :Randomable, "decidim/randomable"
  autoload :Endorsable, "decidim/endorsable"
  autoload :ActionAuthorization, "decidim/action_authorization"

  include ActiveSupport::Configurable
  # Loads seeds from all engines.
  def self.seed!
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

      Organization.all.each do |organization|
        ContextualHelpSection.set_content(
          organization,
          manifest.name,
          Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.sentence(15)
          end
        )
      end
    end

    Gamification.badges.each do |badge|
      puts "Setting random values for the \"#{badge.name}\" badge..."
      User.all.find_each do |user|
        Gamification::BadgeScore.find_or_create_by!(
          user: user,
          badge_name: badge.name,
          value: Random.rand(0...20)
        )
      end
    end

    I18n.available_locales = original_locale
  end

  # Exposes a configuration option: The application name String.
  config_accessor :application_name

  # Exposes a configuration option: The email String to use as sender in all
  # the mails.
  config_accessor :mailer_sender

  # Whether SSL should be enabled or not.
  config_accessor :force_ssl do
    true
  end

  # Exposes a configuration option: The application available locales.
  config_accessor :available_locales do
    %w(en ar ca de el es es-MX es-PY eu fi-pl fi fr gl hu id it nl no pl pt pt-BR ru sk sv tr uk)
  end

  # Exposes a configuration option: The application default locale.
  config_accessor :default_locale do
    :en
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
        # It's a component resource
        ref = component.participatory_space.organization.reference_prefix
      elsif resource.is_a?(Decidim::Participable)
        # It's a participatory space
        ref = resource.organization.reference_prefix
      end

      class_identifier = resource.class.name.demodulize[0..3].upcase
      year_month = (resource.created_at || Time.current).strftime("%Y-%m")

      [ref, class_identifier, year_month, resource.id].join("-")
    end
  end

  # Exposes a configuration option: the whitelist ips
  config_accessor :system_accesslist_ips do
    []
  end

  # Exposes a configuration option: the currency unit
  config_accessor :currency_unit do
    "€"
  end

  # Exposes a configuration option: The image uploader quality.
  config_accessor :image_uploader_quality do
    80
  end

  # Exposes a configuration option: The maximum file size of an attachment.
  config_accessor :maximum_attachment_size do
    10.megabytes
  end

  # Exposes a configuration option: The maximum file size for user avatar images.
  config_accessor :maximum_avatar_size do
    5.megabytes
  end

  # The number of reports which a resource can receive before hiding it
  config_accessor :max_reports_before_hiding do
    3
  end

  # Allow organization's administrators to inject custom HTML into the frontend
  config_accessor :enable_html_header_snippets do
    true
  end

  # Allow organization's administrators to track newsletter links
  config_accessor :track_newsletter_links do
    true
  end

  # Time that data portability files are available in server
  config_accessor :data_portability_expiry_time do
    7.days
  end

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  config_accessor :throttling_max_requests do
    100
  end

  # Time window in which the throttling is applied.
  config_accessor :throttling_period do
    1.minute
  end

  # Time window were users can access the website even if their email is not confirmed.
  config_accessor :unconfirmed_access_for do
    2.days
  end

  # How long can a user remained logged in before the session expires
  config_accessor :expire_session_after do
    1.day
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
    nil
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

  # The Decidim::Exporters::CSV's default column separator
  config_accessor :default_csv_col_sep do
    ";"
  end

  # Exposes a configuration option: HTTP_X_FORWADED_HOST header follow-up.
  # If a caching system is in place, it can also allow cache and log poisoning attacks,
  # allowing attackers to control the contents of caches and logs that could be used for other attacks.
  config_accessor :follow_http_x_forwarded_host do
    false
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
      engine: engine
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
  def self.register_component(name, &block)
    component_registry.register(name, &block)
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
  def self.register_participatory_space(name, &block)
    participatory_space_registry.register(name, &block)
  end

  # Public: Registers a resource.
  #
  # Returns nothing.
  def self.register_resource(name, &block)
    resource_registry.register(name, &block)
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
    component_registry.manifests
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

  # Public: Stores the registry of resource spaces
  def self.resource_registry
    @resource_registry ||= ManifestRegistry.new(:resources)
  end

  # Public: Stores the registry for user permissions
  def self.permissions_registry
    @permissions_registry ||= PermissionsRegistry.new
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
  def self.menu(name, &block)
    MenuRegistry.register(name.to_sym, &block)
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

  # Public: Stores an instance of MetricRegistry
  def self.metrics_registry
    @metrics_registry ||= MetricRegistry.new
  end

  # Public: Stores an instance of MetricOperation
  def self.metrics_operation
    @metrics_operation ||= MetricOperation.new
  end
end
