# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessGroupsController < Decidim::ApplicationController
    helper_method :participatory_processes, :group, :collection

    before_action :set_group

    def show
      authorize! :read, ParticipatoryProcessGroup
    end

    private

    def participatory_processes
      @participatory_processes ||= group.participatory_processes.published
    end
    alias collection participatory_processes

    def set_group
      @group = Decidim::ParticipatoryProcessGroup.find(params[:id])
    end

    attr_reader :group
  end
end
