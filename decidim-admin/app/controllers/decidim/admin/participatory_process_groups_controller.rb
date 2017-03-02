# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessGroupsController < ApplicationController
      helper_method :collection, :participatory_process_group

      def index
        authorize! :read, ParticipatoryProcessGroup
      end

      def show
        authorize! :read, participatory_process_group
      end

      private

      def participatory_process_group
        @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(params[:id])
      end

      def collection
        @collection ||= current_user.organization.participatory_process_groups
      end
    end
  end
end
