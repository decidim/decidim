# frozen_string_literal: true
require "virtus"

module Decidim
  module Components
    class BaseManifest
      def self.inherited(klass)
        Decidim.register_component(klass)
      end

      def self.config
        @config ||= {}
        @config
      end

      def self.component_name(name)
        config[:name] = name.to_sym
      end

      def self.engine(klass)
        config[:engine] = klass
      end

      def self.admin_engine(klass)
        config[:admin_engine] = klass
      end
    end
  end
end
