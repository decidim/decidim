# frozen_string_literal: true

module Decidim
  module Assemblies
    # A presenter to render statistics in an Assembly.
    class AssemblyStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      def assembly
        __getobj__.fetch(:assembly)
      end

      private

      def participatory_space
        assembly
      end

      def participatory_space_sym
        :assemblies
      end
    end
  end
end
