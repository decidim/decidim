# frozen_string_literal: true
module Decidim
  # This class infers the current feature we're scoped to by looking at the
  # request parameters and injects it into the environment.
  class CurrentFeature
    # Initializes the CurrentFeature finder.
    #
    # request - The request that holds the current feature relevant
    # information.
    def initialize(request)
      @request = request
      @env = request.env
    end

    # Public: Injects the current feature into the environment.
    #
    # Returns nothing.
    def call
      @env["decidim.current_feature"] ||= detect_current_feature(@request.params)
    end

    private

    def detect_current_feature(params)
      return nil unless params[:feature_id]

      organization = @env["decidim.current_organization"]

      participatory_process = organization.participatory_processes.find_by(
        id: params[:participatory_process_id]
      )

      return nil unless participatory_process

      participatory_process.features.find_by(id: params[:feature_id])
    end
  end
end
