# frozen_string_literal: true
module Decidim
  # A Helper to render and link to resources.
  module ResourceHelper
    # Builds the path to a resource. Useful when linking to a resource from
    # another engine.
    #
    # resource - An object that is a valid resource exposed by some feature.
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def decidim_resource_path(resource, options = {})
      _decidim_resource_route(resource, "path", options)
    end

    # Builds the url to a resource. Useful when linking to a resource from
    # another engine.
    #
    # resource - An object that is a valid resource exposed by some feature.
    # options - An optional hash of options to pass to the Rails router
    #
    # Returns a String.
    def decidim_resource_url(resource, options = {})
      _decidim_resource_route(resource, "url", options)
    end

    # Renders a collection of linked resources for a resource.
    #
    # resource  - The resource to get the links from.
    # type      - The String type fo the resources we want to render.
    # link_name - The String name of the link between the resources.
    #
    # Example to render the proposals in a meeting view:
    #
    #  linked_resources_for(:meeting, :proposals, "proposals_from_meeting")
    #
    # Returns nothing.
    def linked_resources_for(resource, type, link_name)
      linked_resources = resource.linked_resources(type, link_name).group_by { |linked_resource| linked_resource.class.name }

      safe_join(linked_resources.map do |klass, resources|
        resource_manifest = klass.constantize.resource_manifest
        content_tag(:div, class: "section") do
          content_tag(:h3, I18n.t(resource_manifest.name, scope: "decidim.resource_links.#{link_name}"), class: "section-heading") +
            render(partial: resource_manifest.template, locals: { resources: resources })
        end
      end)
    end

    # Private: Build the route to a given resource.
    #
    # Returns a String.
    def _decidim_resource_route(resource, route_type, options)
      manifest = resource.class.resource_manifest
      engine = send(manifest.mounted_engine_name)

      url_params = {
        id: resource.id,
        feature_id: resource.feature.id,
        participatory_process_id: resource.feature.participatory_process.id
      }

      engine.send("#{manifest.route_name}_#{route_type}", url_params, options)
    end
  end
end
