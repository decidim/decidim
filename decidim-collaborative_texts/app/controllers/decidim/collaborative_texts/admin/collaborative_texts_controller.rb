# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class CollaborativeTextsController < Admin::ApplicationController
        include Decidim::CollaborativeTexts::Admin::Filterable

        helper_method :collaborative_texts, :collaborative_text
        def index; end

        def new
          @form = form(CollaborativeTextForm).instance
        end

        def create
          @form = form(CollaborativeTextForm).from_params(params)

          CreateCollaborativeText.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborative_texts.create.success", scope: "decidim.collaborative_texts.admin")
              redirect_to collaborative_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborative_texts.create.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(CollaborativeTextForm).from_model(collaborative_text)
        end

        def update
          @form = form(CollaborativeTextForm).from_params(params)

          UpdateCollaborativeText.call(@form, collaborative_text) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborative_texts.update.success", scope: "decidim.collaborative_texts.admin")
              redirect_to collaborative_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborative_texts.update.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "edit"
            end
          end
        end

        def publish
          Decidim::CollaborativeTexts::Admin::PublishCollaborativeText.call(collaborative_text, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborative_texts.publish.success", scope: "decidim.collaborative_texts.admin")
              redirect_to collaborative_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborative_texts.publish.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "index"
            end
          end
        end

        def unpublish
          Decidim::CollaborativeTexts::Admin::UnpublishCollaborativeText.call(collaborative_text, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborative_texts.unpublish.success", scope: "decidim.collaborative_texts.admin")
              redirect_to collaborative_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborative_texts.unpublish.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "index"
            end
          end
        end

        private

        def collaborative_texts
          @collaborative_texts ||= filtered_collection
        end

        def collaborative_text
          @collaborative_text ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Document.where(component: current_component)
        end
      end
    end
  end
end
