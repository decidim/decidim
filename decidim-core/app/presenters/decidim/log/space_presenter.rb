# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present the space of the resource of any
    # activity log. The data needed for this class to work should be sent by
    # `Decidim::Log::BasePresenter` or any of its children.
    #
    # In order to be able to use your own class to present a space, you'll need to
    # overwrite `BasePresenter#space_presenter` to return your custom space presenter.
    # The only requirement for custom renderers is that they should respond to `present`.
    class SpacePresenter
      # Public: Initializes the presenter.
      #
      # space - An instance of a model implementing the Decidim::Participable concern
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      # extra -  a Hash with extra data, most likely coming from the
      #   `action_log` being presented
      def initialize(space, view_helpers, extra)
        @space = space
        @view_helpers = view_helpers
        @extra = extra
      end

      # Public: Renders the given space.
      #
      # Returns an HTML-safe String.
      def present
        present_space
      end

      private

      attr_reader :space, :view_helpers, :extra
      alias h view_helpers

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_space
        return h.content_tag(:span, present_space_name, class: "logs__log__space") if space.blank?

        h.link_to(present_space_name, space_path, class: "logs__log__space")
      end

      # Private: Finds the link for the given space.
      #
      # Returns an HTML-safe String.
      def space_path
        Decidim::ResourceLocatorPresenter.new(space).path
      end

      # Private: Presents the space name.
      #
      # Returns an HTML-safe String.
      def present_space_name
        h.translated_attribute extra["title"]
      end
    end
  end
end
