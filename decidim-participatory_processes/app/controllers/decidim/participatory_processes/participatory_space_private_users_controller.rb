# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatorySpacePrivateUsersController < Decidim::ParticipatoryProcesses::ApplicationController
      include ParticipatorySpaceContext
      include Decidim::HasMembersPage

      def index
        raise ActionController::RoutingError, "No members for this participatory process" if members.none?

        enforce_permission_to :list, :members
        redirect_to decidim_participatory_processes.participatory_process_path(current_participatory_space, locale: current_locale) unless can_visit_index?
      end

      private

      def current_participatory_space
        return unless params[:participatory_process_slug]

        @current_participatory_space ||= OrganizationParticipatoryProcesses.new(current_organization).query.where(slug: params[:participatory_process_slug]).or(
          OrganizationParticipatoryProcesses.new(current_organization).query.where(id: params[:participatory_process_slug])
        ).first!
      end
    end
  end
end
