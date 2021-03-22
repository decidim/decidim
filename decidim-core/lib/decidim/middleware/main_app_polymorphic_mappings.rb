# frozen_string_literal: true

module Decidim
  module Middleware
    class MainAppPolymorphicMappings
      def initialize(app)
        @app = app
      end

      def call(env)
        main_app_polymorphic_mappings = Rails.application.routes.polymorphic_mappings
        decidim_engines.each do |klass|
          klass.routes.polymorphic_mappings.merge! main_app_polymorphic_mappings
        end

        @app.call(env)
      end

      def decidim_engines
        Rails::Engine.descendants.select { |klass| klass.name.deconstantize.starts_with?("Decidim::") }
      end
    end
  end
end
