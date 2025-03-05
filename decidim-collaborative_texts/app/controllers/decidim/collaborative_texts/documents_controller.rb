# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::Paginable
      include Decidim::FormFactory

      helper_method :documents, :document, :paginate_documents

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless document
      end

      # roll out a new version of the document (only admins)
      def update
        @form = form(RolloutForm).from_params(params, document:)
        Rollout.call(@form) do
          on(:ok) do
            render json: { redirect: Decidim::ResourceLocatorPresenter.new(document).edit }
          end

          on(:invalid) do
            render json: { message: I18n.t("document.rollout.invalid", scope: "decidim.collaborative_texts", errors: @form.errors.full_messages) }, status: :unprocessable_entity
          end
        end
      end

      private

      def document
        @document ||= documents.find(params[:id])
      end

      def documents
        @documents ||= if current_user&.admin?
                         Document.where(component: current_component)
                       else
                         Document.published.where(component: current_component)
                       end
      end

      def paginate_documents
        @paginate_documents ||= paginate(documents.published.enabled_desc)
      end
    end
  end
end
