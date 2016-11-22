# frozen_string_literal: true
module Decidim
  module Components
    # This Rails' route constraint applies to routes that are scoped to a
    # particular component. It makes sure the type of the component in the route
    # is the right one and matches accordingly.
    class RouteConstraint
      def initialize(component)
        @component_manifest = component
      end

      def matches?(request)
        component_name = @component_manifest.name
        component = CurrentComponent.new(request).call
        component && component.component_type.to_sym == component_name
      end
    end
  end
end
