# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class DocumentsController < Admin::ApplicationController
        include Decidim::CollaborativeTexts::Admin::Filterable
        include Decidim::Admin::HasTrashableResources

        helper_method :documents, :document

        def index
          enforce_permission_to :read, :collaborative_text
        end

        def new
          enforce_permission_to :create, :collaborative_text
          @form = form(DocumentForm).instance
        end

        def create
          enforce_permission_to :create, :collaborative_text
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
          enforce_permission_to(:update, :collaborative_text, document:)
          @form = form(DocumentForm).from_model(document)
        end

        def update
          enforce_permission_to(:update, :collaborative_text, document:)
          @form = form(DocumentForm).from_params(params)

          UpdateDocument.call(@form, document) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.update.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.update.invalid", scope: "decidim.collaborative_texts.admin")
              # This is a safe-guard in case there's no body coming from the POST request (as this attribute is read-only in certain cases)
              @form.body = document.body if @form.body.blank?
              render action: "edit"
            end
          end
        end

        def edit_settings
          enforce_permission_to(:update, :collaborative_text, document:)
          @form = form(Admin::DocumentForm).from_model(document)
        end

        def update_settings
          enforce_permission_to(:update, :collaborative_text, document:)
          @form = form(Admin::DocumentForm).from_params(params)

          UpdateDocumentSettings.call(@form, document) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.update_settings.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.update_settings.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "edit_settings"
            end
          end
        end

        def publish
          enforce_permission_to(:update, :collaborative_text, document:)
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
          enforce_permission_to(:update, :collaborative_text, document:)
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

        def trashable_deleted_resource_type
          :document
        end

        def trashable_deleted_resource
          @trashable_deleted_resource ||= collection.with_deleted.find_by(id: params[:id])
        end

        def trashable_deleted_collection
          @trashable_deleted_collection = filtered_collection.only_deleted.deleted_at_desc
        end

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
