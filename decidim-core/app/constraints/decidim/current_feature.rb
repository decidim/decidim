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

      @participatory_space = env["decidim.current_participatory_space"]
      return false unless @participatory_space

      current_feature(env, request.params) ? true : false
    end

    private

    def current_feature(env, params)
      env["decidim.current_feature"] ||= detect_current_feature(params)
    end

    def detect_current_feature(params)
      @participatory_space.features.find do |feature|
        params["feature_id"] == feature.id.to_s && feature.manifest_name == @manifest.name.to_s
      end
    end
  end
end
