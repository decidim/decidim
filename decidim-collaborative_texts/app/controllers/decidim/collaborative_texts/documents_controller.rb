# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::Paginable
      include Decidim::FormFactory
      include Decidim::AjaxPermissionHandler
      include Decidim::FilterResource

      helper_method :documents, :document, :paginate_documents

      def index
        enforce_permission_to :read, :collaborative_text
      end

      def show
        enforce_permission_to(:read, :collaborative_text, document:)

        raise ActionController::RoutingError, "Not Found" unless document
      end

      # roll out a new version of the document (only admins)
      def update
        enforce_permission_to(:rollout, :collaborative_text, document:)

        @form = form(RolloutForm).from_params(params, document:)
        Rollout.call(@form) do
          on(:ok) do
            render json: { redirect: @form.draft? ? presenter.edit : presenter.path }
          end

          on(:invalid) do
            render json: { message: I18n.t("document.rollout.invalid", scope: "decidim.collaborative_texts", errors: @form.errors.full_messages) }, status: :unprocessable_content
          end
        end
      end

      private

      def document
        @document ||= search_collection.find_by(id: params[:id])
      end

      def presenter
        @presenter ||= Decidim::ResourceLocatorPresenter.new(document)
      end

      def documents
        @documents ||= search.result
      end

      def search_collection
        base = Document.includes(:component).where(component: current_component)
        current_user&.admin? ? base : base.published
      end

      def default_filter_params
        { with_any_state: nil }
      end

      def paginate_documents
        @paginate_documents ||= paginate(documents.enabled_desc)
      end

      def add_breadcrumb_item
        return {} if document.blank?

        {
          label: translated_attribute(document.title),
          url: Decidim::EngineRouter.main_proxy(current_component).document_path(document),
          active: false
        }
      end
    end
  end
end
