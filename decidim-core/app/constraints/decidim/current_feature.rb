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
      feature = detect_current_feature(request)
      return false unless feature

      request.env["decidim.current_participatory_process"] ||= feature.participatory_process
      request.env["decidim.current_feature"] ||= feature
      true
    end

    private

    def detect_current_feature(request)
      params = request.params
      env = request.env

      return nil unless params[:feature_id]

      organization = env["decidim.current_organization"]

      Feature.includes(:participatory_process).where(
        id: params[:feature_id],
        manifest_name: @manifest.name,
        decidim_participatory_processes: {
          id: params[:participatory_process_id],
          decidim_organization_id: organization.id
        }
      ).first
    end
  end
end
