# frozen_string_literal: true
module Decidim
  module Components
    class RouteConstraint
      def initialize(component)
        @component_manifest = component
      end

      def matches?(request)
        # TODO: check current organization
        component_name = @component_manifest.config[:name]
        component = CurrentComponent.new(request).call
        component && component.component_type.to_sym == component_name
      end
    end
  end
end
