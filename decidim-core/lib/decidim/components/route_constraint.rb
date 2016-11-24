# frozen_string_literal: true
module Decidim
  module Components
    # This Rails' route constraint applies to routes that are scoped to a
    # particular component. It makes sure the type of the component in the route
    # is the right one and matches accordingly.
    class RouteConstraint
      # Public: Initializes a RouteConstraint.
      #
      # manifest - The manifest to constrain to.
      def initialize(manifest)
        @manifest = manifest
      end

      # Public: Matches if the request provided should be routed to the engine
      # associated to a particular component manifest. It relies on having a
      # current component present on the scope.
      #
      # What happens behind the scenes is that Rails' router keeps trying
      # manifest over manifest to find a suitable engine to run a particular
      # component. Each component has a public interface managed by a
      # Rails::Engine.
      #
      # request - The request that should be used to perform the matching.
      #
      # Returns True if it matches, False if not.
      def matches?(request)
        component = CurrentComponent.new(request).call
        component && component.component_type.to_sym == @manifest.name
      end
    end
  end
end
