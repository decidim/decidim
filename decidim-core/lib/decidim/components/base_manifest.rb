# frozen_string_literal: true

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

      def self.engine(klass)
        config[:engine] = klass
      end

      def self.name(name)
        config[:name] = name.to_sym
      end

      def self.attribute(name, options = {})
        config[:attributes] ||= {}
        config[:attributes].merge!(name => options)
      end
    end
  end
end
