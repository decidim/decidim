# frozen_string_literal: true
require "virtus"

module Decidim
  module Components
    # Decidim's Base manifest is the main interfice in which `Components` can be
    # hooked into `Decidim`.
    #
    # You can think of components like pieces of external rails application's
    # (engines) that get hooked into participatory processes, allowing us to
    # develop in an isolated environment, without having to carry all the
    # cognitive weight of the rest of the app.
    #
    # Components expose a single publicly-facing Engine, and can optionally
    # provide an admin engine as well, in case we need further private interface
    # (think of moderation, etc).
    class BaseManifest
      # Public: Name of the component to register. It should be globally unique.
      #
      # name - A symbol with the component's name.
      #
      # Returns nothing.
      def self.component_name(name)
        config[:name] = name.to_sym
      end

      # Public: Class of the main Rails engine that will be shown on the
      # participatory process.
      #
      # klass - The name of the Rails Engine constant.
      #
      # Returns nothing.
      def self.engine(klass)
        config[:engine] = klass
      end

      # Public: Class of the Rails engine that will be shown on the
      # participatory process' admin.
      #
      # klass - A name of the Rails Engine constant.
      def self.admin_engine(klass)
        config[:admin_engine] = klass
      end

      # Public: Registers actions to be done given some events produced by the
      # component.
      #
      # name - The name of the event to hook to.
      # block - A block to be executed when that event happens.
      #
      # Returns nothing.
      def self.on(name, &block)
        config[:hooks] ||= {}
        config[:hooks][name.to_sym] = block
      end

      # Public: Exposes the configuration of this component manifest to consumers.
      #
      # Returns a Hash with this component's options.
      def self.config
        @config ||= {}
        @config
      end

      # Private: Hook that gets called automatically when a component inherits
      # from this class.
      #
      # Returns nothing.
      def self.inherited(klass)
        Decidim.register_component(klass)
      end
    end
  end
end
