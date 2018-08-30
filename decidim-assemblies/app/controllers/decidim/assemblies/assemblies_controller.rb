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

      helper_method :collection, :promoted_assemblies, :assemblies, :stats, :assembly_participatory_processes

      def index
        enforce_permission_to :list, :assembly

        respond_to do |format|
          format.html do
            raise ActionController::RoutingError, "Not Found" if published_assemblies.none?

            render "index"
          end

          format.json do
            render json: collection.query.includes(:children).where(parent: nil).collect { |a|
              {
                name: a.title[I18n.locale.to_s],
                children: a.children.collect do |c|
                  {
                    name: c.title[I18n.locale.to_s],
                    children: c.children.collect { |sc| { name: sc.title[I18n.locale.to_s] } }
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
    end
  end
end
