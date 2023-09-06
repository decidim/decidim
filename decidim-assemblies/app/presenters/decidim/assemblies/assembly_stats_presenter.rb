# frozen_string_literal: true

module Decidim
  module Assemblies
    # A presenter to render statistics in an Assembly.
    class AssemblyStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def participatory_space = __getobj__.fetch(:assembly)

      def participatory_space_sym = :assemblies
    end
  end
end
