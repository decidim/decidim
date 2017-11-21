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
      @diff_renderer ||= Decidim::Accountability::DiffRenderer.new(current_version)
    end

    # Renders the diff between `:old_data` and `:new_data` keys in the `data` param.
    #
    # data - A Hash with `old_data`, `:new_data` and `:type` keys.
    #
    # Returns an HTML-safe string.
    def render_diff_data(data)
      content_tag(:div, class: "card card--list diff diff-#{data[:type]}") do
        if [:i18n, :i18n_html].include?(data[:type])
          render_diff_value(
            "&nbsp;",
            data[:type],
            nil,
            data: {
              old_value: data[:old_value].to_s.gsub("</p>", "</p>\n"),
              new_value: data[:new_value].to_s.gsub("</p>", "</p>\n")
            }
          )
        else
          render_diff_value(data[:old_value], data[:type], :removal) +
            render_diff_value(data[:new_value], data[:type], :addition)
        end
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
