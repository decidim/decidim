# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsController < ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::AttachmentsHelper

      helper_method :elections, :election, :tab_panel_items, :questions

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

      def questions
        @questions ||= election.questions if election
      end

      def tab_panel_items
        @tab_panel_items ||= attachments_tab_panel_items(@election)
      end
    end
  end
end
