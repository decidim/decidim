# frozen_string_literal: true

module Decidim
  module Assemblies
    # A presenter to render statistics in an Assembly.
    class AssemblyStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def scope_entity = __getobj__.fetch(:assembly)
    end
  end
end
