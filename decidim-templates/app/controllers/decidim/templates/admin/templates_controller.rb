# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class TemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::Templates::Admin::Filterable
        helper_method :current_template
        layout "decidim/admin/templates"

        def index
          enforce_permission_to :read, :template_list
          @templates = filtered_collection
        end

        def new
          enforce_permission_to :create, :template
          @form = form(AssemblyForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          enforce_permission_to :create, :template
          @form = form(AssemblyForm).from_params(params)

          CreateAssembly.call(@form) do
            on(:ok) do |template|
              flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
              redirect_to templates_path(q: { parent_id_eq: template.parent_id })
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("templates.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :template, template: current_template
          @form = form(AssemblyForm).from_model(current_template)
          render layout: "decidim/admin/template"
        end

        def update
          enforce_permission_to :update, :template, template: current_template
          @form = form(AssemblyForm).from_params(
            template_params,
            template_id: current_template.id
          )

          UpdateAssembly.call(current_template, @form) do
            on(:ok) do |template|
              flash[:notice] = I18n.t("templates.update.success", scope: "decidim.admin")
              redirect_to edit_template_path(template)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("templates.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/template"
            end
          end
        end

        def copy
          enforce_permission_to :create, :template
        end

        private

        def collection
          @collection ||= OrganizationTemplates.new(current_user.organization).query
        end

        def current_template
          @current_template ||= Decidim::Templates::Template.find_by(id: params[:id])
        end

        def template_params
          {
            attr: params[:attr]
          }.merge(params[:template].to_unsafe_h)
        end
      end
    end
  end
end
