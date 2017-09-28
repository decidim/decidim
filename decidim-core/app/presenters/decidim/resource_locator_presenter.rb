# frozen_string_literal: true

module Decidim
  # A presenter to get the url or path from a resource.
  class ResourceLocatorPresenter
    def initialize(resource)
      @resource = resource
    end

    attr_reader :resource

    # Builds the path to the resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def path(options = {})
      member_route("path", options)
    end

    # Builds the url to the resource. Useful when linking to a resource from
    # another engine.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def url(options = {})
      member_route("url", options.merge(host: resource.organization.host))
    end

    # Builds the index path to the associated collection of resources.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def index(options = {})
      collection_route("path", options)
    end

    private

    # Private: Build the route to the resource.
    #
    # Returns a String.
    def member_route(route_type, options)
      route_proxy.send("#{member_route_name}_#{route_type}", resource, options)
    end

    # Private: Build the route to the associated collection of resources.
    #
    # Returns a String.
    def collection_route(route_type, options)
      route_proxy.send("#{collection_route_name}_#{route_type}", options)
    end

    def manifest
      resource.class.try(:resource_manifest) ||
        resource.class.try(:participatory_space_manifest)
    end

    def feature
      resource.feature if resource.respond_to?(:feature)
    end

    def member_route_name
      manifest.route_name
    end

    def collection_route_name
      member_route_name.pluralize
    end

    def route_proxy
      @route_proxy ||= EngineRouter.main_proxy(feature || resource)
    end
  end
end
