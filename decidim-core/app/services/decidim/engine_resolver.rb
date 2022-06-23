# frozen_string_literal: true

module Decidim
  # This class can be used to resolve the mounted route based on the current
  # routes in any provided context.
  class EngineResolver
    # Initializes the engine resolver instance.
    #
    # @param current_routes [ActionDispatch::Routing::RouteSet] the route set
    #  for the context
    def initialize(current_routes)
      @current_routes = current_routes
    end

    # Resolves the mounted route name for the provided context.
    #
    # @return [String] The resolved route name or "decidim" if it could not be
    #   resolved
    def mounted_name
      return "main_app" if base_engine.routes == current_routes

      route = find_mounted_route(base_engine)
      route&.name || "decidim"
    end

    private

    attr_reader :current_routes

    # Provides the base engine from which the search is started from.
    #
    # @return [Rails::Engine] The engine to start the search from
    def base_engine
      Rails.application
    end

    # Finds the mounted route for current context based on the current routes.
    #
    # @param target_engine [Rails::Engine] The engine from which the search is
    #   performed.
    # @return [ActionDispatch::Journey::Route] The defined route that matches
    #   the current context based on the current routes provided for the
    #   initializer.
    def find_mounted_route(target_engine)
      target_engine.routes.set.each do |route|
        # If the route is a dispatcher
        # (ActionDispatch::Routing::RouteSet::Dispatcher), it won't have an
        # engine app mapped to it in which case the app won't respond to the
        # `routes` method.
        next if route.dispatcher?
        next unless route.app.app.is_a?(Class)
        next unless route.app.app < Rails::Engine

        # route.app -> ActionDispatch::Routing::Mapper::Constraints
        # route.app.app -> the target engine
        return route if route.app.app.routes == current_routes

        # Test the sub-engines if any engines are mounted to this engine.
        sub = find_mounted_route(route.app.app)
        return sub if sub
      end

      nil
    end
  end
end
