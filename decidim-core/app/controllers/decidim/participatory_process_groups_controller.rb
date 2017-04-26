# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  class ParticipatoryProcessGroupsController < ApplicationController
    helper_method :participatory_processes, :group, :collection

    def show
      authorize! :read, ParticipatoryProcessGroup
    end

    private

    def participatory_processes
      @participatory_processes ||= group.participatory_processes.published
    end
    alias collection participatory_processes

    def group
      Decidim::ParticipatoryProcessGroup.find(params[:id])
    end
  end
end
