# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class QuestionnaireTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::TranslatableAttributes

        skip_before_action :verify_authenticity_token, only: :preview

        helper_method :template

        def index
          enforce_permission_to :index, :templates
          @templates = collection

          respond_to do |format|
            format.html { render :index }
            format.json do
              term = params[:term]

              @templates = search(term)

              render json: @templates.map { |t| { value: t.id, label: translated_attribute(t.name) } }
            end
          end
        end

        def new
          enforce_permission_to :create, :template
          @form = form(TemplateForm).instance
        end

        def create
          enforce_permission_to :create, :template

          @form = form(TemplateForm).from_params(params)

          CreateQuestionnaireTemplate.call(@form) do
            on(:ok) do |questionnaire_template|
              flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
              redirect_to edit_questionnaire_template_path(questionnaire_template)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("templates.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def copy
          enforce_permission_to :copy, :template

          CopyQuestionnaireTemplate.call(template, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.copy.success", scope: "decidim.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash[:alert] = I18n.t("templates.copy.error", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def edit
          enforce_permission_to :update, :template, template: template
          @form = form(TemplateForm).from_model(template)
          @preview_form = form(Decidim::Forms::QuestionnaireForm).from_model(template.templatable)
        end

        def update
          enforce_permission_to :update, :template, template: template
          @form = form(TemplateForm).from_params(params)
          UpdateTemplate.call(template, @form, current_user) do
            on(:ok) do |questionnaire_template|
              flash[:notice] = I18n.t("templates.update.success", scope: "decidim.admin")
              redirect_to edit_questionnaire_template_path(questionnaire_template)
            end

            on(:invalid) do |template|
              @template = template
              flash.now[:error] = I18n.t("templates.update.error", scope: "decidim.admin")
              render action: :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :template, template: template

          DestroyTemplate.call(template, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def apply
          questionnaire = Decidim::Forms::Questionnaire.find_by(id: params[:questionnaire_id])
          template = Decidim::Templates::Template.find_by(id: params.dig(:questionnaire, :questionnaire_template_id))

          ApplyQuestionnaireTemplate.call(questionnaire, template) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.apply.success", scope: "decidim.admin")
              redirect_to URI.parse(params[:url]).path
            end
            on(:invalid) do
              flash[:error] = I18n.t("templates.apply.error", scope: "decidim.admin")
              redirect_to EngineRouter.admin_proxy(questionnaire.questionnaire_for.component).survey_path
            end
          end
        end

        def preview
          respond_to do |format|
            format.js do
              @template = template
              @questionnaire = @template.templatable
              @preview_form = form(Decidim::Forms::QuestionnaireForm).from_model(@questionnaire)
            end
          end
        end

        def skip
          questionnaire = Decidim::Forms::Questionnaire.find_by(id: params[:questionnaire_id])
          # rubocop:disable Rails/SkipsModelValidations
          questionnaire.touch
          # rubocop:enable Rails/SkipsModelValidations
          redirect_to URI.parse(params[:url]).path
        end

        private

        def collection
          @collection ||= current_organization.templates.where(templatable_type: "Decidim::Forms::Questionnaire")
        end

        def template
          @template ||= Template.find_by(id: params[:id])
        end

        def search(term)
          locales = current_organization.available_locales
          @templates
            .where(locales.map { |l| "name ->> '#{l}' ILIKE :text" }.join(" OR "), text: "%#{term}%")
            .or(@templates.where(locales.map { |l| "description ->> '#{l}' ILIKE :text" }.join(" OR "), text: "%#{term}%"))
        end
      end
    end
  end
end
