# -*- coding: utf-8 -*-
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
  autoload :ResourceManifest, "decidim/resource_manifest"
  autoload :Resourceable, "decidim/resourceable"
  autoload :Reportable, "decidim/reportable"
  autoload :Authorable, "decidim/authorable"
  autoload :Features, "decidim/features"
  autoload :HasAttachments, "decidim/has_attachments"
  autoload :FeatureValidator, "decidim/feature_validator"
  autoload :HasFeature, "decidim/has_feature"
  autoload :HasScope, "decidim/has_scope"
  autoload :HasCategory, "decidim/has_category"
  autoload :HasReference, "decidim/has_reference"
  autoload :Attributes, "decidim/attributes"

  include ActiveSupport::Configurable

  # Loads seeds from all engines.
  def self.seed!
    # Faker needs to have the `:en` locale in order to work properly, so we
    # must enforce it during the seeds.
    original_locale = I18n.available_locales
    I18n.available_locales = original_locale + [:en] unless original_locale.include?(:en)

    railties = Rails.application.railties.to_a.uniq.select do |railtie|
      railtie.respond_to?(:load_seed) && railtie.class.name.include?("Decidim::")
    end

    railties.each do |railtie|
      puts "Creating #{railtie.class.name} seeds..."
      railtie.load_seed
    end

    Decidim.feature_manifests.each do |feature|
      puts "Creating Feature (#{feature.name}) seeds..."
      feature.seed!
    end

    I18n.available_locales = original_locale
  end

  # Exposes a configuration option: The application name String.
  config_accessor :application_name

  # Exposes a configuration option: The email String to use as sender in all
  # the mails.
  config_accessor :mailer_sender

  # Exposes a configuration option: an Array of `cancancan`'s Ability classes
  # that will be automatically included to the base `Decidim::Ability` class.
  config_accessor :abilities do
    []
  end

  # Exposes a configuration option: an Array of `cancancan`'s Ability classes
  # that will be automatically included to the `Decidim::Admin::Abilities::Base`
  # class.
  config_accessor :admin_abilities do
    []
  end

  # Exposes a configuration option: an Array of classes that can be used as
  # AuthorizaionHandlers so users can be verified against different systems.
  config_accessor :authorization_handlers do
    []
  end

  # Exposes a configuration option: The application name String.
  config_accessor :available_locales do
    %w(en ca es eu fi)
  end

  # Exposes a configuration option: an object to configure geocoder
  config_accessor :geocoder

  # Exposes a configuration option: the currency unit
  config_accessor :currency_unit { "€" }

  # Exposes a configuration option: The maximum file size of an attachment.
  config_accessor :maximum_attachment_size do
    10.megabytes
  end

  # The number of reports which an object can receive before hiding it
  config_accessor :max_reports_before_hiding { 3 }

  # A base path for the uploads. If set, make sure it ends in a slash.
  # Uploads will be set to `<base_path>/uploads/`. This can be useful if you
  # want to use the same uploads place for both staging and production
  # environments, but in different folders.
  config_accessor :base_uploads_path { nil }

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
  def self.register_feature(name)
    manifest = FeatureManifest.new(name: name.to_sym)
    yield(manifest)
    manifest.validate!
    feature_manifests << manifest
  end

  # Public: Finds all the registered feature manifest's via the
  # `register_feature` method.
  #
  # Returns an Array[FeatureManifest].
  def self.feature_manifests
    @feature_manifests ||= Set.new
  end

  # Public: Finds a feature manifest by the feature's name.
  #
  # name - The name of the FeatureManifest to find.
  #
  # Returns a FeatureManifest if found, nil otherwise.
  def self.find_feature_manifest(name)
    name = name.to_sym
    feature_manifests.find { |manifest| manifest.name == name }
  end

  # Public: Finds a resource manifest by the resource's name.
  #
  # resource_name_or_class - The String of the ResourceManifest name or the class of
  # the ResourceManifest model_class to find.
  #
  # Returns a ResourceManifest if found, nil otherwise.
  def self.find_resource_manifest(resource_name_or_klass)
    resource_manifests.find do |manifest|
      manifest.model_class == resource_name_or_klass || manifest.name.to_s == resource_name_or_klass.to_s
    end
  end

  # Private: Stores all the resource manifest across all feature manifest.
  #
  # Returns an Array[ResourceManifest]
  def self.resource_manifests
    @resource_manifests ||= feature_manifests.flat_map(&:resource_manifests)
  end

  # Public: Stores all the registered stats
  #
  # Returns a Hash where each key is the name of the registered stat and
  # the value is another Hash containing some stats properties.
  def self.stats
    @stats ||= {}
  end

  # Public: Register a stat
  #
  # name - The name of the stat
  # options - A hash of options
  #         * primary: Wether the stat is primary or not.
  # block - A block that receive the features to filter out the stat.
  def self.register_stat(name, options = {}, block)
    stats[name] = { primary: options.fetch(:primary, false), block: block }
  end

  # Public: Returns a number returned by executing the corresponding block.
  #
  # name - The name of the stat
  # features - An array of Decidim::Feature
  #
  # Returns the result of executing the stats block using the passing features or an error.
  def self.stats_for(name, features)
    return stats[name][:block].call(features) if stats[name].present?
    raise StandardError, "Stats '#{name}' is not registered."
  end
end
