# frozen_string_literal: true
module Decidim
  # This class infers the current component we're scoped to by looking at the
  # request parameters and injects it into the environment.
  class CurrentComponent
    # Initializes the CurrentComponent finder.
    #
    # request - The request that holds the current component relevant
    # information.
    def initialize(request)
      @request = request
      @env = request.env
    end

    # Public: Injects the current component into the environment.
    #
    # Returns nothing.
    def call
      @env["decidim.current_component"] ||= detect_current_component(@request.params)
    end

    private

    def detect_current_component(params)
      return nil unless params[:current_component_id]

      organization = @env["decidim.current_organization"]

      participatory_process = organization.participatory_processes.find_by(
        id: params[:participatory_process_id]
      )

      return nil unless participatory_process

      participatory_process.components.find_by(id: params[:current_component_id])
    end
  end
end
