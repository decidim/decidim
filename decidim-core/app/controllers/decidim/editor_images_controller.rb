# frozen_string_literal: true

module Decidim
  class EditorImagesController < Decidim::ApplicationController
    include FormFactory
    include AjaxPermissionHandler

    def create
      enforce_permission_to :create, :editor_image

      @form = form(EditorImageForm).from_params(form_values)

      CreateEditorImage.call(@form) do
        on(:ok) do |image|
          render json: { url: image.attached_uploader(:file).path, message: I18n.t("success", scope: "decidim.editor_images.create") }
        end

        on(:invalid) do |_message|
          render json: { message: I18n.t("error", scope: "decidim.editor_images.create") }, status: :unprocessable_entity
        end
      end
    end

    private

    def form_values
      {
        file: params[:image],
        author_id: current_user.id
      }
    end

    def permission_scope
      :admin
    end
  end
end
