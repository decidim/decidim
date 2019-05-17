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
               author: Decidim.traceability.last_editor(resource)
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
               author: Decidim.traceability.version_editor(version)
             }
    end

    # Caches a DiffRenderer instance for the `current_version`.
    def diff_renderer
      @diff_renderer ||= if current_version.item_type.include? "Decidim::Proposals"
                           Decidim::Proposals::DiffRenderer.new(current_version)
                         elsif current_version.item_type.include? "Decidim::Accountability"
                           Decidim::Accountability::DiffRenderer.new(current_version)
                         end
    end

    private

    # Renders the given value in a user-friendly way based on the value class.
    #
    # value - an object to be rendered
    #
    # Returns an HTML-ready String.
    def render_diff_value(value, type, action, options = {})
      return "".html_safe if value.blank?

      value_to_render = case type
                        when :date
                          l value, format: :long
                        when :percentage
                          number_to_percentage value, precision: 2
                        else
                          value
                        end

      content_tag(:div, class: "card--list__item #{action}") do
        content_tag(:div, class: "card--list__text") do
          content_tag(:div, { class: "diff__value" }.merge(options)) do
            value_to_render
          end
        end
      end
    end
  end
end
