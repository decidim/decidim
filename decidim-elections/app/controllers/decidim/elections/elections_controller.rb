# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsController < ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::AttachmentsHelper
      include Decidim::FilterResource
      include Decidim::Elections::Orderable
      include Decidim::Paginable

      helper_method :elections, :election, :tab_panel_items, :questions, :paginated_elections

      def index
        # enforce_permission_to :read, :election
      end

      def show
        # TODO: permissions
        raise ActionController::RoutingError, "Not Found" unless election
      end

      private

      def elections
        @elections ||= reorder(search.result)
      end

      def election
        @election ||= elections.find_by(id: params[:id])
      end

      def search_collection
        Election.where(component: current_component).not_hidden
      end

      def tab_panel_items
        @tab_panel_items ||= attachments_tab_panel_items(@election)
      end

      def paginated_elections
        @paginated_elections ||= paginate(elections)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_state: "all"
        }
      end
    end
  end
end
