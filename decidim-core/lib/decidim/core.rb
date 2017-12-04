# frozen_string_literal: true

require "decidim/core/engine"
require "decidim/core/version"
require "decidim/core/api"

# Decidim configuration.
module Decidim
  autoload :TranslatableAttributes, "decidim/translatable_attributes"
  autoload :FormBuilder, "decidim/form_builder"
  autoload :AuthorizationFormBuilder, "decidim/authorization_form_builder"
  autoload :FilterFormBuilder, "decidim/filter_form_builder"
  autoload :DeviseFailureApp, "decidim/devise_failure_app"
  autoload :FeatureManifest, "decidim/feature_manifest"
  autoload :ParticipatorySpaceManifest, "decidim/participatory_space_manifest"
  autoload :ResourceManifest, "decidim/resource_manifest"
  autoload :Resourceable, "decidim/resourceable"
  autoload :Traceable, "decidim/traceable"
  autoload :Reportable, "decidim/reportable"
  autoload :Authorable, "decidim/authorable"
  autoload :Participable, "decidim/participable"
  autoload :Publicable, "decidim/publicable"
  autoload :Scopable, "decidim/scopable"
  autoload :Features, "decidim/features"
  autoload :HasAttachments, "decidim/has_attachments"
  autoload :FeatureValidator, "decidim/feature_validator"
  autoload :HasSettings, "decidim/has_settings"
  autoload :HasFeature, "decidim/has_feature"
  autoload :HasScope, "decidim/has_scope"
  autoload :HasCategory, "decidim/has_category"
  autoload :Followable, "decidim/followable"
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
  autoload :Abilities, "decidim/abilities"
  autoload :EngineRouter, "decidim/engine_router"
  autoload :Events, "decidim/events"
  autoload :ViewHooks, "decidim/view_hooks"

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

    Decidim.participatory_space_manifests.each(&:seed!)

    I18n.available_locales = original_locale
  end

  # Exposes a configuration option: The application name String.
  config_accessor :application_name

  # Exposes a configuration option: The email String to use as sender in all
  # the mails.
  config_accessor :mailer_sender

  # Exposes a configuration option: an Array of `cancancan`'s Ability classes
  # that will be automatically included to the base `Decidim::Abilities::BaseAbility`
  # class.
  config_accessor :abilities do
    []
  end

  # Exposes a configuration option: an Array of `cancancan`'s Ability classes
  # that will be automatically included to the `Decidim::Admin::Abilities::BaseAbility`
  # class.
  config_accessor :admin_abilities do
    []
  end

  # Exposes a configuration option: The application available locales.
  config_accessor :available_locales do
    %w(en ca es eu it fi fr nl uk ru)
  end

  # Exposes a configuration option: The application default locale.
  config_accessor :default_locale do
    :en
  end

  # Exposes a configuration option: an object to configure geocoder
  config_accessor :geocoder

  # Exposes a configuration option: a custom method to generate references
  # Default: Calculates a unique reference for the model in
  # the following format:
  #
  # "BCN-DPP-2017-02-6589" which in this example translates to:
  #
  # BCN: A setting configured at the organization to be prepended to each reference.
  # PROP: Unique name identifier for a resource: Decidim::Proposals::Proposal (MEET for meetings or PROJ for projects).
  # 2017-02: Year-Month of the resource creation date
  # 6589: ID of the resource
  config_accessor :resource_reference_generator do
    lambda do |resource, feature|
      ref = feature.participatory_space.organization.reference_prefix
      class_identifier = resource.class.name.demodulize[0..3].upcase
      year_month = (resource.created_at || Time.current).strftime("%Y-%m")

      [ref, class_identifier, year_month, resource.id].join("-")
    end
  end

  # Exposes a configuration option: the currency unit
  config_accessor :currency_unit do
    "€"
  end

  # Exposes a configuration option: The maximum file size of an attachment.
  config_accessor :maximum_attachment_size do
    10.megabytes
  end

  # Exposes a configuration option: The maximum file size for user avatar images.
  config_accessor :maximum_avatar_size do
    5.megabytes
  end

  # The number of reports which an object can receive before hiding it
  config_accessor :max_reports_before_hiding do
    3
  end

  # Allow organization's administrators to inject custom HTML into the frontend
  config_accessor :enable_html_header_snippets do
    true
  end

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  config_accessor :base_uploads_path

  # Public: Registers a feature, usually held in an external library or in a
  # separate folder in the main repository. Exposes a DSL defined by
  # `Decidim::FeatureManifest`.
  #
  # Feature manifests are held in a global registry and are used in all kinds of
  # places to figure out what new components or functionalities the feature provides.
  #
  # name - A Symbol with the feature's unique name.
  #
  # Returns nothing.
  def self.register_feature(name, &block)
    feature_registry.register(name, &block)
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

  # Public: Finds all registered feature manifest's via the `register_feature`
  # method.
  #
  # Returns an Array[FeatureManifest].
  def self.feature_manifests
    feature_registry.manifests
  end

  # Public: Finds all registered participatory space manifest's via the
  # `register_participatory_space` method.
  #
  # Returns an Array[ParticipatorySpaceManifest].
  def self.participatory_space_manifests
    participatory_space_registry.manifests
  end

  # Public: Finds a feature manifest by the feature's name.
  #
  # name - The name of the FeatureManifest to find.
  #
  # Returns a FeatureManifest if found, nil otherwise.
  def self.find_feature_manifest(name)
    feature_registry.find(name.to_sym)
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
    feature_registry.find_resource_manifest(resource_name_or_klass)
  end

  # Public: Stores the registry of features
  def self.feature_registry
    @feature_registry ||= ManifestRegistry.new(:features)
  end

  # Public: Stores the registry of participatory spaces
  def self.participatory_space_registry
    @participatory_space_registry ||= ManifestRegistry.new(:participatory_spaces)
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

  # Public: Stores an instance of Traceability
  def self.traceability
    @traceability ||= Traceability.new
  end
end
