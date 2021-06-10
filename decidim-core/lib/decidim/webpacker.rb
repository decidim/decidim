# frozen_string_literal: true

module Decidim
  module Webpacker
    autoload :Configuration, "decidim/webpacker/configuration"
    autoload :Runner, "decidim/webpacker/runner"

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.register_path(path, prepend: false)
      if prepend
        configuration.additional_paths.unshift(path)
      else
        configuration.additional_paths.push(path)
      end
    end

    def self.register_entrypoints(entrypoints)
      configuration.entrypoints.merge!(entrypoints.stringify_keys)
    end
  end
end
