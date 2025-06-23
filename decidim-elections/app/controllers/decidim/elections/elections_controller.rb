# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsController < ApplicationController
      include Decidim::ApplicationHelper

      helper_method :elections, :election

      def index
        # enforce_permission_to :read, :election
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless election
      end

      private

      def elections
        @elections ||= Election.where(component: current_component)
      end

      def election
        @election ||= elections.find_by(id: params[:id]) if params[:id].present?
      end
    end
  end
end
