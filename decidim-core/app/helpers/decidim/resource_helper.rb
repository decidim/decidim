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
      _decidim_resource_route(resource, "url", options.merge(host: resource.organization.host))
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
          i18n_name = "#{resource.class.name.demodulize.underscore}_#{resource_manifest.name}"
          content_tag(:h3, I18n.t(i18n_name, scope: "decidim.resource_links.#{link_name}"), class: "section-heading") +
            render(partial: resource_manifest.template, locals: { resources: resources })
        end
      end)
    end

    # Gets the classes linked to the given class for the `current_feature`, and formats
    # them in a nice way so that they can be used in a form. Resulting format looks like
    # this, considering the given class is related to `Decidim::Meetings::Meeting`:
    #
    #   [["decidim/meetings/meeting", "Meetings"]]
    #
    # This method is intended to be used as a check to render the filter or not. Use the
    # `linked_classes_filter_values_for(klass)` method to get the form filter collection
    # values.
    #
    # klass - The class that will have its linked resources formatted.
    #
    # Returns an Array of Arrays of Strings.
    # Returns an empty Array if no links are found.
    def linked_classes_for(klass)
      return [] unless klass.respond_to?(:linked_classes_for)

      klass.linked_classes_for(current_feature).map do |k|
        [k.underscore, t(k.demodulize.downcase, scope: "decidim.filters.linked_classes")]
      end
    end

    # Uses the `linked_classes_for(klass)` helper method to find the linked classes,
    # and adds a default value to it so that it can be used directly in a form.
    #
    # Example:
    #
    #   <% if linked_classes_for(klass).any? %>
    #     <%= form.collection_check_boxes :related_to, linked_classes_filter_values_for(klass), :first, :last %>
    #   <% end %>
    #
    # klass - The class that will have its linked resources formatted.
    #
    # Returns an Array of Arrays of Strings.
    def linked_classes_filter_values_for(klass)
      [["", t("all", scope: "decidim.filters.linked_classes")]] + linked_classes_for(klass)
    end

    # Private: Build the route to a given resource.
    #
    # Returns a String.
    def _decidim_resource_route(resource, route_type, options)
      manifest = resource.class.resource_manifest
      engine = manifest.feature_manifest.engine

      url_params = {
        id: resource.id,
        feature_id: resource.feature.id,
        participatory_process_id: resource.feature.participatory_process.id
      }

      engine.routes.url_helpers.send("#{manifest.route_name}_#{route_type}", url_params.merge(options))
    end
  end
end
