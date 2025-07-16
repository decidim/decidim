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

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless election

        respond_to do |format|
          format.html { render :show }

          format.json do
            render json: election.to_json
          end
        end
      end

      private

      def elections
        @elections ||= reorder(search.result)
      end

      def election
        @election ||= elections.find_by(id: params[:id])
      end

      def questions
        @questions ||= election.available_questions.includes(:response_options)
      end

      def search_collection
        Election.where(component: current_component).not_hidden.published
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
