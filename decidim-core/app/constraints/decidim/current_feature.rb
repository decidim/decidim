# frozen_string_literal: true
module Decidim
  # This class infers the current feature we're scoped to by looking at the
  # request parameters and injects it into the environment.
  class CurrentFeature
    # Public: Injects the current feature into the environment.
    #
    # request - The request that holds the current feature relevant
    #           information.
    #
    # Returns nothing.
    def matches?(request)
      request.env["decidim.current_feature"] ||= detect_current_feature(request)
    end

    private

    def detect_current_feature(request)
      params = request.params
      env = request.env

      return nil unless params[:feature_id]

      organization = env["decidim.current_organization"]

      participatory_process = organization.participatory_processes.find_by(
        id: params[:participatory_process_id]
      )

      return nil unless participatory_process

      participatory_process.features.find_by(id: params[:feature_id])
    end
  end
end
