# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class infers the current component on a participatory process context
    # request parameters and injects it into the environment.
    class CurrentComponent
      # Public: Initializes the class.
      #
      # manifest - The manifest of the component to check against.
      def initialize(manifest)
        @manifest = manifest
      end

      # Public: Matches the request against a component and injects it into the
      #         environment.
      #
      # request - The request that holds the current component relevant information.
      #
      # Returns a true if the request matches a participatory process and a
      # component belonging to that participatory process, false otherwise
      def matches?(request)
        CurrentParticipatoryProcess.new.matches?(request) &&
          Decidim::CurrentComponent.new(@manifest).matches?(request)
      end
    end
  end
end
