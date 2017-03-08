# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  class ParticipatoryProcessGroupsController < ApplicationController
    helper_method :participatory_processes, :group

    def show
      authorize! :read, ParticipatoryProcessGroup
    end

    private

    def participatory_processes
      @participatory_processes ||= group.participatory_processes.published
    end

    def group
      Decidim::ParticipatoryProcessGroup.find(params[:id])
    end
  end
end
