# frozen_string_literal: true

module Decidim
  # A Helper to find and render the author of a version.
  module TraceabilityHelper
    include Decidim::SanitizeHelper
    # Renders the avatar and author name of the author of the last version of the given
    # resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an HTML-safe String representing the HTML to render the author.
    def render_resource_last_editor(resource)
      render partial: "decidim/shared/version_author",
             locals: {
               author: resource_last_editor(resource)
             }
    end

    # Renders the avatar and author name of the author of the given version.
    #
    # version - an object that responds to `whodunnit` and returns a String.
    #
    # Returns an HTML-safe String representing the HTML to render the author.
    def render_resource_editor(version)
      render partial: "decidim/shared/version_author",
             locals: {
               author: version_author(version)
             }
    end

    # Finds the author of the last version of the resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an object identifiable via GlobalID or a String.
    def resource_last_editor(resource)
      version_author(resource.versions.last)
    end

    # Finds the author of the given version.
    #
    # version - an object that responds to `whodunnit` and returns a String.
    #
    # Returns an object identifiable via GlobalID or a String.
    def version_author(version)
      ::GlobalID::Locator.locate(version.whodunnit) || version.whodunnit
    end

    # Renders the diff of the given changeset. Takes into account translatable fields.
    # To be refactored to a presenter.
    #
    # changeset - a `Version` changeset
    #
    # Returns a Hash, where keys are the fields that have changed and values are an array,
    # the first element being the previous value and the last being the new one.
    def render_diff(changeset)
      changeset.inject({}) do |diff, (attribute, values)|
        if values.first.is_a?(Hash) || values.last.is_a?(Hash)
          values.last.each_key do |key, _value|
            first_value = values.first.try(:[], key)
            last_value = values.last.try(:[], key)
            next if first_value == last_value
            attribute_key = "#{attribute}_#{key}"
            diff.update(attribute_key => [first_value, last_value])
          end
          diff
        else
          diff.update(attribute => values)
        end
      end
    end

    # Renders the given value in a user-friendly way based on the value class.
    # To be refactored to a presenter.
    #
    # value - an object to be rendered
    #
    # Returns a String.
    def render_diff_value(value)
      case value
      when ActiveSupport::TimeWithZone
        l value, format: :long
      when String
        decidim_sanitize value
      else
        value
      end
    end
  end
end
