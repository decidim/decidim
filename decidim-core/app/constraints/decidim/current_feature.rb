# frozen_string_literal: true

module Decidim
  # This class infers the current feature we're scoped to by looking at the
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
    # Returns a true if the request matched, false otherwise
    def matches?(request)
      env = request.env

      return false unless CurrentParticipatoryProcess.new.matches?(request)

      @participatory_process = env["decidim.current_participatory_process"]

      feature = detect_current_feature(request.params)

      return false unless feature

      env["decidim.current_feature"] ||= feature
      true
    end

    private

    def detect_current_feature(params)
      @participatory_process.features.find do |feature|
        params["feature_id"] == feature.id.to_s && feature.manifest_name == @manifest.name.to_s
      end
    end
  end
end
