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
      # changeset - An array of hashes
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      def initialize(changeset, view_helpers)
        @changeset = changeset
        @view_helpers = view_helpers
      end

      # Public: Renders the given diff.
      #
      # Returns an HTML-safe String.
      def present
        present_diff
      end

      private

      attr_reader :changeset, :view_helpers
      alias h view_helpers

      # Private: Presents the diff for this action. If the resource and the
      # version are found in the database, it displays all changes.
      #
      # Returns an HTML-safe String.
      def present_diff
        return "".html_safe unless changeset

        h.content_tag(:div, class: "logs__log__diff") do
          changeset.each do |attribute|
            h.concat(present_new_value(attribute[:label], attribute[:new_value]))
            h.concat(present_previous_value(attribute[:previous_value]))
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
      # label - the label name
      # value - the value for the given label
      #
      # Returns an HTML-safe String.
      def present_new_value(label, value)
        h.content_tag(:div, class: "logs__log__diff-row logs__log__diff-row--new-value") do
          h.concat(h.content_tag(:div, label, class: "logs__log__diff-title"))
          h.concat(h.content_tag(:div, value, class: "logs__log__diff-value"))
        end
      end
    end
  end
end
