# frozen_string_literal: true

module Decidim
  module Assemblies
    # A controller that holds the logic to show Assemblies in a
    # public layout.
    class AssembliesController < Decidim::ApplicationController
      layout "layouts/decidim/assembly", only: [:show]

      before_action -> { extend NeedsAssembly }, only: [:show]

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper

      helper_method :collection, :promoted_assemblies, :assemblies, :stats

      def index
        redirect_to "/404" if published_assemblies.none?

        authorize! :read, Assembly
      end

      def show
        authorize! :read, current_assembly
      end

      private

      def published_assemblies
        @published_assemblies ||= OrganizationPublishedAssemblies.new(current_organization)
      end

      def assemblies
        @assemblies ||= OrganizationPrioritizedAssemblies.new(current_organization)
      end

      alias collection assemblies

      def promoted_assemblies
        @promoted_assemblies ||= assemblies | PromotedAssemblies.new
      end

      def stats
        @stats ||= AssemblyStatsPresenter.new(assembly: current_assembly)
      end
    end
  end
end
