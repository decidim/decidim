# frozen_string_literal: true
module Decidim
  class CurrentComponent
    def initialize(request)
      @request = request
      @env = request.env
    end

    def call
      @env["decidim.current_component"] ||= detect_current_component(@request.params)
    end

    private

    def detect_current_component(params)
      return unless params[:current_component_id]

      organization = @env["decidim.current_organization"]
      participatory_process = organization.participatory_processes.find(params[:participatory_process_id])

      participatory_process.components.find(params[:current_component_id])
    end
  end
end
