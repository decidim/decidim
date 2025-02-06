# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      class SettingsController < Admin::ApplicationController
        helper_method :document

        def index
          @form = form(DocumentForm).from_model(document)
        end

        def create
          @form = form(DocumentForm).from_params(params)

          UpdateDocument.call(@form, document) do
            on(:ok) do
              flash[:notice] = I18n.t("settings.update.success", scope: "decidim.collaborative_texts.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("settings.update.invalid", scope: "decidim.collaborative_texts.admin")
              render action: "index"
            end
          end
        end

        private

        def documents
          @documents ||= Decidim::CollaborativeTexts::Document.where(component: current_component)
        end

        def document
          @document ||= documents.find_by(id: params[:id])
        end
      end
    end
  end
end
