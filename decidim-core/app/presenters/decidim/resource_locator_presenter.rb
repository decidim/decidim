# frozen_string_literal: true

module Decidim
  # A presenter to get the url or path from a resource.
  # resource - a record or array of nested records.
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
      member_route("url", options.merge(host: root_resource.organization.host))
    end

    # Builds the index path to the associated collection of resources.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def index(options = {})
      collection_route("path", options)
    end

    # Builds the admin index path to the associated collection of resources
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def admin_index(options = {})
      admin_collection_route("path", options)
    end

    # Builds the admin show path to the resource.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def show(options = {})
      options.merge!(options_for_polymorphic)

      admin_route_proxy.send("#{member_route_name}_path", target, options)
    end

    # Builds the admin edit path to the resource.
    #
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def edit(options = {})
      options.merge!(options_for_polymorphic)

      admin_route_proxy.send("edit_#{member_route_name}_path", target, options)
    end

    private

    def polymorphic?
      resource.is_a? Array
    end

    def target
      if polymorphic?
        resource.last
      else
        resource
      end
    end

    def root_resource
      if polymorphic?
        resource.first
      else
        resource
      end
    end

    # Private: Build the route to the resource.
    #
    # Returns a String.
    def member_route(route_type, options)
      options.merge!(options_for_polymorphic)

      route_proxy.send("#{member_route_name}_#{route_type}", target, options)
    end

    # Private: Build the route to the associated collection of resources.
    #
    # Returns a String.
    def collection_route(route_type, options)
      options.merge!(options_for_polymorphic)

      route_proxy.send("#{collection_route_name}_#{route_type}", options)
    end

    def admin_collection_route(route_type, options)
      options.merge!(options_for_polymorphic)

      admin_route_proxy.send("#{collection_route_name}_#{route_type}", options)
    end

    def manifest_for(record)
      record.try(:resource_manifest) ||
        record.class.try(:resource_manifest) ||
        record.class.try(:participatory_space_manifest) ||
        record.to_s
    end

    def route_name_for(record)
      manifest = manifest_for(record)

      if manifest.respond_to?(:route_name)
        manifest.route_name
      else
        manifest.to_s
      end
    end

    def component
      root_resource.try(:component)
    end

    def member_route_name
      if polymorphic?
        polymorphic_member_route_name
      else
        route_name_for(target)
      end
    end

    def polymorphic_member_route_name
      return unless polymorphic?

      resource.map { |record| route_name_for(record) }.join("_")
    end

    def collection_route_name
      member_route_name.pluralize
    end

    def options_for_polymorphic
      return {} unless polymorphic?

      parent_resources = {}
      (resource - [target]).each do |parent|
        parent_resources["#{route_name_for(parent)}_id"] = parent.id unless parent.is_a?(String)
      end
      parent_resources
    end

    def route_proxy
      @route_proxy ||= EngineRouter.main_proxy(component || target)
    end

    def admin_route_proxy
      @admin_route_proxy ||= EngineRouter.admin_proxy(component || target)
    end
  end
end
