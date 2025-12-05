# frozen_string_literal: true

module Decidim
  module Assemblies
    class ParticipatorySpacePrivateUsersController < Decidim::Assemblies::ApplicationController
      include ParticipatorySpaceContext
      include Decidim::HasMembersPage

      def index
        raise ActionController::RoutingError, "No members for this assembly" if members.none?

        enforce_permission_to :list, :members
        redirect_to decidim_assemblies.assembly_path(current_participatory_space, locale: I18n.locale) unless can_visit_index?
      end

      private

      def current_participatory_space
        return unless params[:assembly_slug]

        @current_participatory_space ||= OrganizationAssemblies.new(current_organization).query.where(slug: params[:assembly_slug]).or(
          OrganizationAssemblies.new(current_organization).query.where(id: params[:assembly_slug])
        ).first!
      end
    end
  end
end
