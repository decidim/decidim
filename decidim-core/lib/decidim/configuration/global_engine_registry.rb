# frozen_string_literal: true

module Decidim
  module Configuration
    module GlobalEngineRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a global engine. This method is intended to be used
        # by component engines that also offer unscoped functionality
        #
        # name    - The name of the engine to register. Should be unique.
        # engine  - The engine to register.
        # options - Options to pass to the engine.
        #           :at - The route to mount the engine to.
        #
        # Returns nothing.
        def register_global_engine(name, engine, options = {})
          return if global_engines.has_key?(name)

          options[:at] ||= "/#{name}"

          global_engines[name.to_sym] = {
            at: options[:at],
            engine:
          }
        end

        # Semiprivate: Removes a global engine from the registry. Mostly used on testing,
        # no real reason to use this on production.
        #
        # name - The name of the global engine to remove.
        #
        # Returns nothing.
        def unregister_global_engine(name)
          global_engines.delete(name.to_sym)
        end

        # Public: Finds all registered engines via the 'register_global_engine' method.
        #
        # Returns an Array[::Rails::Engine]
        def global_engines
          @global_engines ||= {}
        end
      end
    end
  end
end
