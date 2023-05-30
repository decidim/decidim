# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class BlockUserTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::TranslatableAttributes
        include Decidim::Paginable

        def fetch
          enforce_permission_to(:read, :template, template:)

          response_object = {
            template: translated_attribute(template.description)
          }

          respond_to do |format|
            format.json do
              render json: response_object.to_json
            end
          end
        end

        def copy
          enforce_permission_to :copy, :template

          CopyTemplate.call(template, current_user) do
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

        def destroy
          enforce_permission_to(:destroy, :template, template:)

          DestroyTemplate.call(template, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def update
          enforce_permission_to(:update, :template, template:)
          @form = form(TemplateForm).from_params(params)
          UpdateTemplate.call(template, @form, current_user) do
            on(:ok) do
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

        def edit
          enforce_permission_to(:update, :template, template:)
          @form = form(TemplateForm).from_model(template)
        end

        def create
          enforce_permission_to :create, :template

          @form = form(TemplateForm).from_params(params)

          CreateBlockUserTemplate.call(@form) do
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

        def new
          enforce_permission_to :create, :template
          @form = form(TemplateForm).instance
        end

        def index
          enforce_permission_to :index, :templates
          @templates = paginate(collection)

          respond_to do |format|
            format.html { render :index }
            format.json do
              term = params[:term]

              @templates = search(term)

              render json: @templates.map { |t| { value: t.id, label: translated_attribute(t.name) } }
            end
          end
        end

        private

        def template
          @template ||= collection.find(params[:id])
        end

        def collection
          @collection ||= current_organization.templates.where(target: :user_block)
        end
      end
    end
  end
end
