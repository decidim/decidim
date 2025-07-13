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
      include Decidim::Debates::Orderable
      include Decidim::AttachmentsHelper

      helper_method :debates, :debate, :form_presenter, :paginated_debates, :close_debate_form, :tab_panel_items
      before_action :authenticate_user!, only: [:new, :create]

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
        enforce_permission_to(:edit, :debate, debate:)

        @form = form(DebateForm).from_model(debate)
      end

      def update
        enforce_permission_to(:edit, :debate, debate:)

        @form = form(DebateForm).from_params(params)

        UpdateDebate.call(@form, debate) do
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

      def close
        enforce_permission_to(:close, :debate, debate:)

        @form = form(CloseDebateForm).from_params(params)

        CloseDebate.call(@form) do
          on(:ok) do |debate|
            flash[:notice] = I18n.t("debates.close.success", scope: "decidim.debates")
            redirect_back fallback_location: Decidim::ResourceLocatorPresenter.new(debate).path
          end

          on(:invalid) do
            flash[:alert] = I18n.t("debates.close.invalid", scope: "decidim.debates")
            redirect_back fallback_location: Decidim::ResourceLocatorPresenter.new(debate).path
          end
        end
      end

      private

      def form_presenter
        @form_presenter ||= present(@form, presenter_class: Decidim::Debates::DebatePresenter)
      end

      def paginated_debates
        @paginated_debates ||= paginate(debates).includes(:taxonomies)
      end

      def debates
        @debates ||= reorder(search.result)
      end

      def debate
        @debate ||= debates.find_by(id: params[:id])
      end

      def close_debate_form
        @close_debate_form ||= form(CloseDebateForm).from_model(debate)
      end

      def search_collection
        Debate.where(component: current_component).not_hidden
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_origin: nil,
          activity: "all",
          with_any_taxonomies: nil,
          with_any_state: "all"
        }
      end

      def tab_panel_items
        @tab_panel_items ||= attachments_tab_panel_items(debate)
      end
    end
  end
end
