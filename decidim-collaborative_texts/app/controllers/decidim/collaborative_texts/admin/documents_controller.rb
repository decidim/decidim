# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class DocumentsController < Admin::ApplicationController
        include Decidim::CollaborativeTexts::Admin::Filterable

        helper_method :documents, :document

        def index; end

        def new
          @form = form(DocumentForm).instance
        end

        def create
          @form = form(DocumentForm).from_params(params)

          CreateDocument.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.create.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.create.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(DocumentForm).from_model(document)
        end

        def update
          @form = form(DocumentForm).from_params(params)

          UpdateDocument.call(@form, document) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.update.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.update.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "edit"
            end
          end
        end

        def publish
          Decidim::CollaborativeTexts::Admin::PublishDocument.call(document, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.publish.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.publish.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "index"
            end
          end
        end

        def unpublish
          Decidim::CollaborativeTexts::Admin::UnpublishDocument.call(document, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.unpublish.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.unpublish.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "index"
            end
          end
        end

        private

        def documents
          @documents ||= filtered_collection
        end

        def document
          @document ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Document.where(component: current_component)
        end
      end
    end
  end
end
