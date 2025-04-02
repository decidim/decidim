# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # Exposes the blog resource so users can view them
    class DocumentsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::Paginable

      helper_method :documents, :document, :paginate_documents

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless document
      end

      private

      def document
        @document ||= documents.find(params[:id])
      end

      def documents
        @documents ||= if current_user&.admin?
                         Document.where(component: current_component).published
                       else
                         Document.published.where(component: current_component).published
                       end
      end

      def paginate_documents
        @paginate_documents ||= paginate(documents.enabled_desc)
      end
    end
  end
end
