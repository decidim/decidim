# frozen_string_literal: true
require "decidim/core"
require "decidim/system"
require "decidim/admin"

# Module declaration.
module Decidim
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
end
