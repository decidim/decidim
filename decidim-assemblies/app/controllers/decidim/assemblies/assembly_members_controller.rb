# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyMembersController < Decidim::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :index

      helper_method :collection

      def index
        redirect_to "/404" if current_participatory_space.members.none?

        authorize! :read, AssemblyMember
        redirect_to decidim_assemblies.assembly_path(current_participatory_space) unless current_user_can_visit_space?
      end

      private

      def members
        @members ||= current_participatory_space.members.where(ceased_date: nil)
      end

      alias collection members

      def current_participatory_space
        return unless params[:assembly_slug]

        @current_participatory_space ||= OrganizationAssemblies.new(current_organization).query.where(slug: params[:assembly_slug]).or(
          OrganizationAssemblies.new(current_organization).query.where(id: params[:assembly_slug])
        ).first!
      end
    end
  end
end
