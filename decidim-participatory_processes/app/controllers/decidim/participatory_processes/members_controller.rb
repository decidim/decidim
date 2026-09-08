# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class MembersController < Decidim::ParticipatoryProcesses::ApplicationController
      include ParticipatorySpaceContext
      include Paginable
      include Decidim::ParticipatorySpace::HasMembersPage

      def index
        raise ActionController::RoutingError, "No members for this participatory process" if members.none?

        @members = paginate(members)
        enforce_permission_to :list, :members
        redirect_to decidim_participatory_processes.participatory_process_path(current_participatory_space) unless can_visit_index?
      end

      private

      def current_participatory_space
        return unless params[:participatory_process_slug]

        @current_participatory_space ||= OrganizationParticipatoryProcesses.new(current_organization).query.where(slug: params[:participatory_process_slug]).or(
          OrganizationParticipatoryProcesses.new(current_organization).query.where(id: params[:participatory_process_slug])
        ).first!
      end

      def page_params
        {
          per_page:,
          page: params[:page]
        }
      end
    end
  end
end
