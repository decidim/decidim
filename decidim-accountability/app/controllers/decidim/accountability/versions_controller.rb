# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes result versions so users can see how a result
    # has been updated through time.
    class VersionsController < Decidim::Accountability::ApplicationController
      helper Decidim::Accountability::BreadcrumbHelper
      helper_method :result

      include Decidim::ResourceVersionsConcern

      def versioned_resource
        result
      end

      private

      def result
        @result ||= Result.includes(:milestones).where(component: current_component).find(params.expect(:result_id))
      end

      def add_breadcrumb_item
        return {} if result.blank?

        {
          label: translated_attribute(result.title),
          url: Decidim::EngineRouter.main_proxy(current_component).result_path(result),
          active: false
        }
      end
    end
  end
end
