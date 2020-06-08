# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      module Concerns
        module HasTemplates
          extend ActiveSupport::Concern

          included do
            helper_method :templatable, :template
            delegate :templatable, to: :template

            def index
              @templates = collection
            end

            def new
              enforce_permission_to :create, :template
              @form = form(TemplateForm).instance
            end

            def create
              enforce_permission_to :create, :template

              @form = form(TemplateForm).from_params(params)

              CreateTemplate.call(@form) do
                on(:ok) do
                  flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("templates.create.error", scope: "decidim.admin")
                  render :new
                end
              end
            end

            def copy
              enforce_permission_to :create, :template

              CopyTemplate.call(template) do
                on(:ok) do
                  flash[:notice] = I18n.t("templates.copy.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("templates.copy.error", scope: "decidim.admin")
                  render :index
                end
              end
            end

            def edit
              enforce_permission_to :update, :template, template: template
              @form = form(TemplateForm).from_model(template)
            end

            def update
              enforce_permission_to :update, :template, template: template
              @form = form(TemplateForm).from_params(params)

              UpdateTemplate.call(template, @form, current_user) do
                on(:ok) do |_template|
                  flash[:notice] = I18n.t("templates.update.success", scope: "decidim.admin")
                  redirect_to action: :index
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

                on(:invalid) do
                  flash.now[:error] = I18n.t("templates.destroy.error", scope: "decidim.admin")
                  redirect_to :back
                end
              end
            end

            # Public: Method to be implemented at the controller. You need to
            # return the class for the template.
            def templatable_type
              raise "#{self.class.name} is expected to implement #templatable_type"
            end

            def i18n_flashes_scope
              "decidim.templates.admin"
            end

            private

            def collection
              @collection ||= current_organization.templates.where(templatable_type: templatable_type)
            end

            def template
              @template ||= Template.find_by(id: params[:id])
            end
          end
        end
      end
    end
  end
end
