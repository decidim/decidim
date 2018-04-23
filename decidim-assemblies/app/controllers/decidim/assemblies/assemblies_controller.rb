# frozen_string_literal: true

module Decidim
  module Assemblies
    # A controller that holds the logic to show Assemblies in a
    # public layout.
    class AssembliesController < Decidim::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :show

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper

      helper_method :collection, :promoted_assemblies, :assemblies, :stats, :assembly_participatory_processes

      def index
        redirect_to "/404" if published_assemblies.none?

        authorize! :read, Assembly
      end

      def show
        check_current_user_can_visit_space
      end

      private

      def current_participatory_space
        return unless params[:slug]

        @current_participatory_space ||= OrganizationAssemblies.new(current_organization).query.where(slug: params[:slug]).or(
          OrganizationAssemblies.new(current_organization).query.where(id: params[:slug])
        ).first!
      end

      def published_assemblies
        @published_assemblies ||= OrganizationPublishedAssemblies.new(current_organization, current_user)
      end

      def assemblies
        @assemblies ||= OrganizationPrioritizedAssemblies.new(current_organization, current_user)
      end

      alias collection assemblies

      def promoted_assemblies
        @promoted_assemblies ||= assemblies | PromotedAssemblies.new
      end

      def stats
        @stats ||= AssemblyStatsPresenter.new(assembly: current_participatory_space)
      end

      def assembly_participatory_processes
        @assembly_participatory_processes ||= @current_participatory_space.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
      end

      def current_participatory_space_manifest_name
        :assemblies
      end
    end
  end
end
