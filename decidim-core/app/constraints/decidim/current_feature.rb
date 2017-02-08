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

    # Public: Injects the current feature into the environment.
    #
    # request - The request that holds the current feature relevant
    #           information.
    #
    # Returns nothing.
    def matches?(request)
      env = request.env
      params = request.params

      organization = env["decidim.current_organization"]

      @participatory_process = request.env["decidim.current_participatory_process"] ||
                               organization.participatory_processes.find_by_id(params["participatory_process_id"])

      env["decidim.current_participatory_process"] ||= @participatory_process

      feature = detect_current_feature(request)

      return false unless feature

      env["decidim.current_feature"] ||= feature
      true
    end

    private

    def detect_current_feature(request)
      params = request.params
      return nil unless params["feature_id"]

      @participatory_process.features.to_a.find do |feature|
        params["feature_id"].to_s == feature.id.to_s && feature.manifest_name == @manifest.name.to_s
      end
    end
  end
end
