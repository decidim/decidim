# frozen_string_literal: true

require "decidim/webpacker/thread_safe_compiler"

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

    def self.register_stylesheet_import(import, type: :imports, group: :app)
      type = type.to_s
      key = group.to_s
      configuration.stylesheet_imports[type] ||= {}
      configuration.stylesheet_imports[type][key] ||= []
      configuration.stylesheet_imports[type][key].push(import)
    end

    def self.register_redesigned_stylesheet_import(import, type: :imports, group: :redesigned_app)
      import = import.sub(%r{.*\K/(_?)}, "/\\1redesigned_") if !%r{.*\K/_?redesigned}.match?(import)

      register_stylesheet_import(import, type: type, group: group)
    end
  end
end
