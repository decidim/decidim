# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class infers the current feature on a participatory process context
    # request parameters and injects it into the environment.
    class CurrentFeature
      # Public: Initializes the class.
      #
      # manifest - The manifest of the feature to check against.
      def initialize(manifest)
        @manifest = manifest
      end

      # Public: Matches the request against a feature and injects it into the
      #         environment.
      #
      # request - The request that holds the current feature relevant information.
      #
      # Returns a true if the request matches a participatory process and a
      # feature belonging to that participatory process, false otherwise
      def matches?(request)
        CurrentParticipatoryProcess.new.matches?(request) &&
          Decidim::CurrentFeature.new(@manifest).matches?(request)
      end
    end
  end
end
