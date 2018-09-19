# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LastActivityCell < Decidim::ViewModel
      include Decidim::CardHelper
      include Decidim::IconHelper
      include Decidim::Core::Engine.routes.url_helpers

      delegate :current_organization, to: :controller

      def show
        return if last_activity.blank?
        render
      end

      def activity_cell_for(resource)
        cell_name = resource.class.name.underscore
        "#{cell_name}_activity"
      end

      def last_activity
        @last_activity ||= Decidim::ActionLog
                           .where(organization: current_organization)
                           .includes(:resource)
                           .public
                           .order(created_at: :desc)
                           .limit(8)
                           .load
      end
    end
  end
end
