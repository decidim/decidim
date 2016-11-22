# frozen_string_literal: true
require "decidim/core/engine"
require "decidim/core/version"

# Decidim configuration.
module Decidim
  autoload :TranslatableAttributes, "decidim/translatable_attributes"
  autoload :FormBuilder, "decidim/form_builder"
  autoload :AuthorizationFormBuilder, "decidim/authorization_form_builder"
  autoload :DeviseFailureApp, "decidim/devise_failure_app"
  autoload :FeatureManifest, "decidim/feature_manifest"

  include ActiveSupport::Configurable

  # Loads seeds from all engines.
  def self.seed!
    Rails.application.railties.select do |railtie|
      railtie.respond_to?(:load_seed) && railtie.class.name.include?("Decidim::")
    end.each(&:load_seed)
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

  # Exposes a configuration option: an Array of classes that can be used as
  # AuthorizaionHandlers so users can be verified against different systems.
  config_accessor :authorization_handlers do
    []
  end

  # Exposes a configuration option: The application name String.
  config_accessor :available_locales do
    %w(en ca es)
  end

  def self.register_feature(name, &block)
    feature = FeatureManifest.new(name: name)
    yield(feature)
    feature.validate!
    features << feature
  end

  def self.components
    features.map(&:components).map(&:to_a).flatten
  end

  def self.features
    @features ||= Set.new
    @features
  end
end
