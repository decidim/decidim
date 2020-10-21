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
      # options - a Hash with options
      def initialize(changeset, view_helpers, options = {})
        @changeset = changeset
        @view_helpers = view_helpers
        @options = { show_previous_value?: true }.merge(options)
      end

      # Public: Renders the given diff.
      #
      # Returns an HTML-safe String.
      def present
        present_diff
      end

      private

      attr_reader :changeset, :view_helpers, :options
      alias h view_helpers

      # Private: Presents the diff for this action. If the resource and the
      # version are found in the database, it displays all changes.
      #
      # Returns an HTML-safe String.
      def present_diff
        return "".html_safe if changeset.blank?

        h.content_tag(:div, class: "logs__log__diff") do
          changeset.each do |attribute|
            h.concat(present_new_value(attribute[:label], attribute[:new_value], attribute[:type]))
            h.concat(present_previous_value(attribute[:previous_value], attribute[:type])) if options[:show_previous_value?]
          end
        end
      end

      # Private: Helper method to render the previous value.
      #
      # value - the value for the given attribute
      # type - A symbol or String representing the type of the value.
      #   If it's a String, it should be the name of the presenter that will
      #   be in charge of presenting it.
      #
      # Returns an HTML-safe String.
      def present_previous_value(value, type)
        h.content_tag(:div, class: "logs__log__diff-row logs__log__diff-row--previous-value") do
          h.concat(h.content_tag(:div, "before", class: "logs__log__diff-title"))
          h.concat(h.content_tag(:div, present_value(value, type), class: "logs__log__diff-value"))
        end
      end

      # Private: Helper method to render the new value.
      #
      # label - the label name
      # value - the value for the given label
      # type - A symbol or String representing the type of the value.
      #   If it's a String, it should be the name of the presenter that will
      #   be in charge of presenting it.
      #
      # Returns an HTML-safe String.
      def present_new_value(label, value, type)
        h.content_tag(:div, class: "logs__log__diff-row logs__log__diff-row--new-value") do
          h.concat(h.content_tag(:div, label, class: "logs__log__diff-title"))
          h.concat(h.content_tag(:div, present_value(value, type), class: "logs__log__diff-value"))
        end
      end

      # Private: Presents the value with the its type presenter.
      #
      # value - the value to be presented, no specific type.
      # type - A symbol or String representing the type of the value.
      #   If it's a String, it should be the name of the presenter that will
      #   be in charge of presenting it.
      #
      # Returns an HTML-safe String.
      def present_value(value, type)
        presenter_klass_for(type).new(value, view_helpers).present
      end

      # Private: Finds the presenter class for the given type.
      #
      # type - A symbol or String representing the type of the value.
      #   If it's a String, it should be the name of the presenter that will
      #   be in charge of presenting it.
      #
      # Returns a Class.
      def presenter_klass_for(type)
        default_klass = Decidim::Log::ValueTypes::DefaultPresenter
        klass = ""

        case type
        when Symbol
          klass = "Decidim::Log::ValueTypes::#{type.to_s.camelize}Presenter"
        when String
          klass = type
        end

        begin
          klass.constantize
        rescue NameError => _e
          default_klass
        end
      end
    end
  end
end
