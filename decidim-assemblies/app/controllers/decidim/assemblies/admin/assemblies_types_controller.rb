# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller used to manage the available assemblies types for the current
      # organization.
      # As this substitues former i18n simple hash we need to keep these i18n keys for migrations
      # and rollbakcs. So let i18n-tasks know about:
      # i18n-tasks-use t('decidim.assemblies.assembly_types.government')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.commission')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.consultative_advisory')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.executive')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.others')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.participatory')
      # i18n-tasks-use t('decidim.assemblies.assembly_types.working_group')
      # This comment (and the i18n keys) may be removed in future versions
      class AssembliesTypesController < Decidim::Assemblies::Admin::ApplicationController
        helper_method :available_assemblies_types, :current_assembly_type
        layout "decidim/admin/assemblies"

        # GET /admin/assemblies_types
        def index
          enforce_permission_to :index, :assembly_type
        end

        # GET /admin/assemblies_types/new
        def new
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.instance
        end

        # POST /admin/assemblies_types
        def create
          enforce_permission_to :create, :assembly_type
          @form = assembly_type_form.from_params(params)

          CreateAssembliesType.call(@form) do
            on(:ok) do |_assembly_type|
              flash[:notice] = I18n.t("assemblies_types.create.success", scope: "decidim.admin")
              redirect_to assemblies_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_types.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        # GET /admin/assemblies_types/:id/edit
        def edit
          enforce_permission_to :edit, :assembly_type, assembly_type: current_assembly_type
          @form = assembly_type_form
                  .from_model(current_assembly_type,
                              assembly_type: current_assembly_type)
        end

        # PUT /admin/assemblies_types/:id
        def update
          enforce_permission_to :update, :assembly_type, assembly_type: current_assembly_type

          @form = assembly_type_form
                  .from_params(params, assembly_type: current_assembly_type)

          UpdateAssembliesType.call(current_assembly_type, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_types.update.success", scope: "decidim.admin")
              redirect_to assemblies_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_types.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        # DELETE /admin/assemblies_types/:id
        def destroy
          enforce_permission_to :destroy, :assembly_type, assembly_type: current_assembly_type

          DestroyAssembliesType.call(current_assembly_type, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_types.destroy.success", scope: "decidim.admin")
              redirect_to assemblies_types_path
            end
          end
        end

        private

        def available_assemblies_types
          @available_assemblies_types ||= AssembliesType.where(organization: current_organization)
        end

        def current_assembly_type
          @current_assembly_type ||= AssembliesType.find(params[:id])
        end

        def assembly_type_form
          form(Decidim::Assemblies::Admin::AssembliesTypeForm)
        end
      end
    end
  end
end
