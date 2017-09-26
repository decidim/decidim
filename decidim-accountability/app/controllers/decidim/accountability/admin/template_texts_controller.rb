# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage template texts per Accountability feature
      class TemplateTextsController < Admin::ApplicationController
        helper_method :template_texts

        def edit
          @form = form(TemplateTextsForm).from_model(template_texts)
        end

        def update
          @form = form(TemplateTextsForm).from_params(params)

          UpdateTemplateTexts.call(@form, template_texts) do
            on(:ok) do
              flash[:notice] = I18n.t("template_texts.update.success", scope: "decidim.accountability.admin")
              redirect_to edit_template_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("template_texts.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        private

        def template_texts
          @template_texts ||= TemplateTexts.for(current_feature)
        end
      end
    end
  end
end
