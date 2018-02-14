# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present the diff for any activity log.
    # The data needed for this class to work should be sent by
    # `Decidim::Log::BasePresenter` or any of its children.
    #
    # In order to be able to use your own class to present a diff, you'll need to
    # overwrite `BasePresenter#diff_presenter` to return your custom diff presenter.
    # The only requirement for custom renderers is that they should respond to `present`.
    class DiffPresenter
      # Public: Initializes the presenter.
      #
      # resource - An instance of a model that can be located by
      #   `Decidim::ResourceLocatorPresenter`
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      # extra -  a Hash with extra data, most likely coming from the
      #   `action_log` being presented
      def initialize(resource, view_helpers, extra)
        @resource = resource
        @view_helpers = view_helpers
        @extra = extra
      end

      # Public: Renders the given diff.
      #
      # Returns an HTML-safe String.
      def present
        present_diff
      end

      # Public: Checks if the diff is visible or not.
      #
      # Returns a Boolean.
      def visible?
        version.present?
      end

      private

      attr_reader :resource, :view_helpers, :extra
      alias h view_helpers

      # Private: Presents the diff for this action. If the resource and the
      # version are found in the database, it displays all changes.
      #
      # Returns an HTML-safe String.
      def present_diff
        return "".html_safe unless version

        h.content_tag(:div, class: "logs__log__diff") do
          clean_changeset.each do |attribute, (old_value, new_value)|
            h.concat(present_new_value(attribute, new_value))
            h.concat(present_previous_value(attribute, old_value))
          end
        end
      end

      # Private: Helper method to render the previous value.
      #
      # value - the value for the given attribute
      #
      # Returns an HTML-safe String.
      def present_previous_value(value)
        h.content_tag(:div, class: "logs__log__diff-row logs__log__diff-row--previous-value") do
          h.concat(h.content_tag(:div, "before", class: "logs__log__diff-title"))
          h.concat(h.content_tag(:div, value, class: "logs__log__diff-value"))
        end
      end

      # Private: Helper method to render the new value.
      #
      # attribute - the attribute name
      # value - the value for the given attribute
      #
      # Returns an HTML-safe String.
      def present_new_value(attribute, value)
        h.content_tag(:div, class: "logs__log__diff-row logs__log__diff-row--new-value") do
          h.concat(h.content_tag(:div, attribute, class: "logs__log__diff-title"))
          h.concat(h.content_tag(:div, value, class: "logs__log__diff-value"))
        end
      end

      # Private: Caches the version that holds the changeset to display.
      #
      # Returns a PaperTrail::Version.
      def version
        @version ||= PaperTrail::Version.where(id: extra["id"]).first
      end

      # Private: Removes some fields from the changeset that should not be rendered.
      #
      # Returns a Hash with `<attribute_name> => [<old_value>, <new_value>]`.
      def clean_changeset
        @clean_changeset ||= version.changeset.except("updated_at")
      end
    end
  end
end
