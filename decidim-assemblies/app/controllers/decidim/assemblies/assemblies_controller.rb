# frozen_string_literal: true

module Decidim
  module Assemblies
    # A controller that holds the logic to show Assemblies in a
    # public layout.
    class AssembliesController < Decidim::Assemblies::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :show

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper

      helper_method :collection, :parent_assemblies, :promoted_assemblies, :assemblies, :stats, :assembly_participatory_processes

      def index
        enforce_permission_to :list, :assembly

        respond_to do |format|
          format.html do
            raise ActionController::RoutingError, "Not Found" if published_assemblies.none?

            render "index"
          end

          format.json do
            render json: published_assemblies.query.includes(:children).where(parent: nil).collect { |assembly|
              {
                name: assembly.title[I18n.locale.to_s],
                children: assembly.children.collect do |child|
                  {
                    name: child.title[I18n.locale.to_s],
                    children: child.children.collect { |child_of_child| { name: child_of_child.title[I18n.locale.to_s] } }
                  }
                end
              }
            }
          end
        end
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

      def parent_assemblies
        @parent_assemblies ||= assemblies | ParentAssemblies.new
      end

      alias collection parent_assemblies

      def promoted_assemblies
        @promoted_assemblies ||= assemblies | PromotedAssemblies.new
      end

      def stats
        @stats ||= AssemblyStatsPresenter.new(assembly: current_participatory_space)
      end

      def assembly_participatory_processes
        @assembly_participatory_processes ||= @current_participatory_space.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
      end
    end
  end
end
