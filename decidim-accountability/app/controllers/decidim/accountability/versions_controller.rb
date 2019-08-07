# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes result versions so users can see how a result
    # has been updated through time.
    class VersionsController < Decidim::Accountability::ApplicationController
      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper
      helper_method :current_version, :result

      private

      def result
        @result ||= Result.includes(:timeline_entries).where(component: current_component).find(params[:result_id])
      end

      def current_version
        return nil if params[:id].to_i < 1

        @current_version ||= result.versions[params[:id].to_i - 1]
      end
    end
  end
end
