# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present the resource for any activity log.
    # The data needed for this class to work should be sent by
    # `Decidim::Log::BasePresenter` or any of its children.
    #
    # In order to be able to use your own class to present a resource, you'll need to
    # overwrite `BasePresenter#resource_presenter` to return your custom resource presenter.
    # The only requirement for custom renderers is that they should respond to `present`.
    class ResourcePresenter
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

      # Public: Renders the given resource.
      #
      # Returns an HTML-safe String.
      def present
        present_resource
      end

      private

      attr_reader :resource, :view_helpers, :extra
      alias h view_helpers

      # Private: Presents the resource of the action. If the resource and the
      # space are found in the database, it links to it. Otherwise it only
      # shows the resource name.
      #
      # Returns an HTML-safe String.
      def present_resource
        if resource.blank? || resource_path.blank?
          h.content_tag(:span, present_resource_name, class: "logs__log__resource")
        else
          h.link_to(present_resource_name, resource_path, class: "logs__log__resource")
        end
      end

      # Private: Finds the public link for the given resource.
      #
      # Returns an HTML-safe String. If the resource space is not
      # present, it returns `nil`.
      def resource_path
        @resource_path ||= begin
          Decidim::ResourceLocatorPresenter.new(resource).path
        rescue NoMethodError
          nil
        end
      end

      # Private: Presents resource name.
      #
      # Returns an HTML-safe String.
      def present_resource_name
        h.translated_attribute extra["title"]
      end
    end
  end
end
