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
      include Flaggable

      helper_method :debates, :debate, :paginated_debates, :report_form

      def new
        enforce_permission_to :create, :debate

        @form = form(DebateForm).instance
      end

      def create
        enforce_permission_to :create, :debate

        @form = form(DebateForm).from_params(params)

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

      def show
        raise ActionController::RoutingError, "Not Found" if debate.blank?
      end

      def edit
        enforce_permission_to :edit, :debate, debate: debate

        @form = form(DebateForm).from_model(debate)
      end

      def update
        enforce_permission_to :edit, :debate, debate: debate

        @form = form(DebateForm).from_params(params)
        @form.debate = debate

        UpdateDebate.call(@form) do
          on(:ok) do |debate|
            flash[:notice] = I18n.t("debates.update.success", scope: "decidim.debates")
            redirect_to Decidim::ResourceLocatorPresenter.new(debate).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("debates.update.invalid", scope: "decidim.debates")
            render :edit
          end
        end
      end

      private

      def paginated_debates
        @paginated_debates ||= paginate(debates).includes(:category)
      end

      def debates
        @debates ||= search.results
      end

      def debate
        @debate ||= debates.find_by(id: params[:id])
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
