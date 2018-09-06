# frozen_string_literal: true

module Decidim
  module Debates
    # Exposes the debate resource so users can view them
    class DebatesController < Decidim::Debates::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::Messaging::ConversationHelper
      include FormFactory
      include FilterResource
      include Paginable

      helper_method :debates, :debate, :paginated_debates, :report_form

      def show
        debate
      end

      def new
        enforce_permission_to :create, :debate

        @form = form(DebateForm).instance
      end

      def create
        enforce_permission_to :create, :debate

        @form = form(DebateForm).from_params(params, current_component: current_component)

        CreateDebate.call(@form) do
          on(:ok) do |debate|
            flash[:notice] = I18n.t("debates.create.success", scope: "decidim.debates")
            redirect_to Decidim::ResourceLocatorPresenter.new(debate).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("debates.create.invalid", scope: "decidim.debates")
            render action: "new"
          end
        end
      end

      private

      def paginated_debates
        @paginated_debates ||= paginate(debates)
                               .includes(:category)
      end

      def debates
        @debates ||= search.results.not_hidden
      end

      def debate
        @debate ||= debates.find(params[:id])
      end

      def report_form
        @report_form ||= form(Decidim::ReportForm).from_params(reason: "spam")
      end

      def search_klass
        DebateSearch
      end

      def default_search_params
        {
          page: params[:page],
          per_page: 12
        }
      end

      def default_filter_params
        {
          search_text: "",
          order_start_time: "asc",
          origin: "all",
          category_id: ""
        }
      end
    end
  end
end
