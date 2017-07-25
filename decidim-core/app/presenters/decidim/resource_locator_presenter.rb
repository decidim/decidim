# frozen_string_literal: true

module Decidim
  # A presenter to get the url or path from a resource.
  class ResourceLocatorPresenter
    def initialize(resource)
      @resource = resource
    end

    # Builds the path to the resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def path(options = {})
      _route("path", options)
    end

    # Builds the url to the resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def url(options = {})
      _route("url", options.merge(host: @resource.organization.host))
    end

    private

    # Private: Build the route to the resource.
    #
    # Returns a String.
    def _route(route_type, options)
      route_proxy.send("#{member_route_name}_#{route_type}", member_params.merge(options))
    end

    def manifest
      @resource.class.resource_manifest
    end

    def feature
      @resource.feature
    end

    def engine
      manifest.feature_manifest.engine
    end

    def member_params
      {
        id: @resource.id,
        feature_id: feature.id,
        participatory_process_id: feature.participatory_process.id
      }
    end

    def member_route_name
      manifest.route_name
    end

    def route_proxy
      engine.routes.url_helpers
    end
  end
end
