# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module ResourceHelper
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
        [k.underscore, content_tag(:span, t(k.demodulize.underscore, scope: "decidim.filters.linked_classes"))]
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
      [["", content_tag(:span, t("all", scope: "decidim.filters.linked_classes"))]] + linked_classes_for(klass)
    end

    # Returns an instance of ResourceLocatorPresenter with the given resource
    def resource_locator(resource)
      return resource.resource_locator if resource.respond_to?(:resource_locator)

      ::Decidim::ResourceLocatorPresenter.new(resource)
    end
  end
end
