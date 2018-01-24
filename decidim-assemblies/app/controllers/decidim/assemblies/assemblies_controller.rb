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

      helper_method :collection, :promoted_assemblies, :assemblies, :stats

      def index
        redirect_to "/404" if published_assemblies.none?

        authorize! :read, Assembly
      end

      def show
        redirect_to "/404" unless (current_participatory_space.private_assembly? &&
                           current_participatory_space.users.any? { current_user }) ||
                                  !current_participatory_space.private_assembly?
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
    end
  end
end
