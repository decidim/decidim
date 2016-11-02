# frozen_string_literal: true
require "decidim/core/engine"
require "decidim/core/version"

# Decidim configuration.
module Decidim
  autoload :TranslatableAttributes, "decidim/translatable_attributes"
  autoload :FormBuilder, "decidim/form_builder"
  autoload :DeviseFailureApp, "decidim/devise_failure_app"
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
end
