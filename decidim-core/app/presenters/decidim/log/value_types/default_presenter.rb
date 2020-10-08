# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class is used as a base for other value presenters,
      # and as a default presenter when the presenter for the
      # given value is not specified or is not found.
      #
      # Value presenters are dynamically found from the value type
      # set in the `fields_mapping` method in the resource presenter.
      # If the value is a symbol, the system will try to infer the
      # correct presenter and use it. If it's a String, it will treat
      # it as a class name, and will try to fetch that presenter.
      # If the system fails in either case, it will use the `DefaultPresenter`.
      #
      # Check the other presenters in this folder for more examples.
      class DefaultPresenter
        # value - the value to render, can be of any type.
        # view_helpers - an object encapsulating all the view helpers,
        #   it will most likely come from the top of the chain.
        def initialize(value, view_helpers)
          @value = value
          @view_helpers = view_helpers
        end

        # Public: Presents the value in a specific format. In this method
        # you can use any view helper you need, but it's important to return
        # an HTML-safe String.
        #
        # Returns an HTML-safe String.
        def present
          value
        end

        private

        attr_reader :value, :view_helpers
        alias h view_helpers
      end
    end
  end
end
