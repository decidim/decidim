# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      module Concerns
        module HasSettings
          extend ActiveSupport::Concern
          included do
            include Decidim::TranslatableAttributes

            helper_method :document

            def edit_settings
              @form = form(Admin::DocumentForm).from_model(document)
            end

            def update_settings
              @form = form(Admin::DocumentForm).from_params(params)

              UpdateDocument.call(@form, document) do
                on(:ok) do
                  flash[:notice] = I18n.t("documents.update_settings.success", scope: "decidim.collaborative_texts.admin")
                  redirect_to documents_path
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("documents.update_settings.invalid", scope: "decidim.collaborative_texts.admin")
                  render template: edit_settings_template
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

            def edit_settings_template
              "decidim/collaborative_texts/admin/documents/edit_settings"
            end
          end
        end
      end
    end
  end
end
