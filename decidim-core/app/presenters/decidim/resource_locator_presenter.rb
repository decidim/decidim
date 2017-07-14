# frozen_string_literal: true

module Decidim
  # A presenter to get the url or path from a resource.
  class ResourceLocatorPresenter
    def initialize(resource)
      @resource = resource
    end

    # Builds the path to a resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def path(options = {})
      _route("path", options)
    end

    # Builds the url to a resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def url(options = {})
      _route("url", options.merge(host: @resource.organization.host))
    end

    private

    # Private: Build the route to a given resource.
    #
    # Returns a String.
    def _route(route_type, options)
      manifest = @resource.class.resource_manifest
      engine = manifest.feature_manifest.engine

      url_params = {
        id: @resource.id,
        feature_id: @resource.feature.id,
        participatory_process_id: @resource.feature.participatory_process.id
      }

      engine.routes.url_helpers.send("#{manifest.route_name}_#{route_type}", url_params.merge(options))
    end
  end
end
