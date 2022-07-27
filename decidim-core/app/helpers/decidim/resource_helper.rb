# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module ResourceHelper
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
            render(partial: resource_manifest.template, locals: { resources: })
        end
      end)
    end

    # Gets the classes linked to the given class for the `current_component`, and formats
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

      klass.linked_classes_for(current_component).map do |k|
        [k.underscore, t(k.demodulize.underscore, scope: "decidim.filters.linked_classes")]
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

    # Returns an instance of ResourceLocatorPresenter with the given resource
    def resource_locator(resource)
      ::Decidim::ResourceLocatorPresenter.new(resource)
    end

    # Returns a descriptive title for the resource
    def resource_title(resource)
      title = resource.try(:title) || resource.try(:name) || resource.try(:subject) || "#{resource.model_name.human} ##{resource.id}"
      title = translated_attribute(title) if title.is_a?(Hash)
      title
    end
  end
end
