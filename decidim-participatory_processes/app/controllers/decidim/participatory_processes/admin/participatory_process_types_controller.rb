# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller used to manage participatory process types for the current
      # organization
      class ParticipatoryProcessTypesController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        helper_method :collection, :current_participatory_process_type
        layout "decidim/admin/participatory_process_type"

        # GET /admin/participatory_process_types
        def index
          enforce_permission_to :index, :participatory_process_type
        end

        # GET /admin/participatory_process_types/new
        def new
          enforce_permission_to :create, :participatory_process_type
          @form = participatory_process_type_form.instance
        end

        # POST /admin/participatory_process_types
        def create
          enforce_permission_to :create, :participatory_process_type
          @form = participatory_process_type_form.from_params(params)

          CreateParticipatoryProcessType.call(@form) do
            on(:ok) do |_process_type|
              flash[:notice] = I18n.t("participatory_process_types.create.success", scope: "decidim.admin")
              redirect_to participatory_process_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_types.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        # GET /admin/participatory_process_types/:id/edit
        def edit
          enforce_permission_to :edit, :participatory_process_type, participatory_process_type: current_participatory_process_type
          @form = participatory_process_type_form.from_model(
            current_participatory_process_type,
            participatory_process_type: current_participatory_process_type
          )
        end

        # PUT /admin/participatory_process_types/:id
        def update
          enforce_permission_to :update, :participatory_process_type, participatory_process_type: current_participatory_process_type

          @form = participatory_process_type_form
                  .from_params(params, participatory_process_type: current_participatory_process_type)

          UpdateParticipatoryProcessType.call(current_participatory_process_type, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_types.update.success", scope: "decidim.admin")
              redirect_to participatory_process_types_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_types.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        # DELETE /admin/participatory_process_types/:id
        def destroy
          enforce_permission_to :destroy, :participatory_process_type, participatory_process_type: current_participatory_process_type

          DestroyParticipatoryProcessType.call(current_participatory_process_type, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_types.destroy.success", scope: "decidim.admin")
              redirect_to participatory_process_types_path
            end
          end
        end

        private

        def participatory_process_type_form
          form(Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessTypeForm)
        end

        def current_participatory_process_type
          @current_participatory_process_type ||= Decidim::ParticipatoryProcessType.find(params[:id])
        end

        def collection
          @collection ||= Decidim::ParticipatoryProcessType.where(organization: current_organization)
        end
      end
    end
  end
end
