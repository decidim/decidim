# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsController < ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::AttachmentsHelper
      include FilterResource
      include Decidim::Elections::Orderable
      include Paginable

      helper_method :elections, :election, :voter, :tab_panel_items, :questions, :paginated_elections

      def index
        # enforce_permission_to :read, :election
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless election
      end

      private

      def elections
        @elections ||= reorder(search.result)
      end

      def questions
        @questions ||= election.questions if election
      end

      def election
        @election ||= elections.find_by(id: params[:id])
      end

      def voter
        @voter ||= Decidim::Elections::Voter.with_email(current_user&.email).find_by(election_id: election.id)
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
