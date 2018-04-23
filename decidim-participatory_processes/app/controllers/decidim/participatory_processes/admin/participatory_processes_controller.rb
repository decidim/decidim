# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory processes.
      #
      class ParticipatoryProcessesController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        participatory_space_admin_layout only: [:edit]

        helper ProcessGroupsForSelectHelper

        helper_method :current_participatory_process, :current_participatory_space

        layout "decidim/admin/participatory_processes"

        def index
          authorize! :index, Decidim::ParticipatoryProcess
          @participatory_processes = collection
        end

        def new
          authorize! :new, Decidim::ParticipatoryProcess
          @form = form(ParticipatoryProcessForm).instance
        end

        def create
          authorize! :new, Decidim::ParticipatoryProcess
          @form = form(ParticipatoryProcessForm).from_params(params)

          CreateParticipatoryProcess.call(@form) do
            on(:ok) do |participatory_process|
              flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
              redirect_to participatory_process_steps_path(participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          authorize! :update, current_participatory_process
          @form = form(ParticipatoryProcessForm).from_model(current_participatory_process)
          render layout: "decidim/admin/participatory_process"
        end

        def update
          authorize! :update, current_participatory_process
          @form = form(ParticipatoryProcessForm).from_params(
            participatory_process_params,
            process_id: current_participatory_process.id
          )

          UpdateParticipatoryProcess.call(current_participatory_process, @form) do
            on(:ok) do |participatory_process|
              flash[:notice] = I18n.t("participatory_processes.update.success", scope: "decidim.admin")
              redirect_to edit_participatory_process_path(participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/participatory_process"
            end
          end
        end

        def destroy
          authorize! :destroy, current_participatory_process
          current_participatory_process.destroy!

          flash[:notice] = I18n.t("participatory_processes.destroy.success", scope: "decidim.admin")

          redirect_to participatory_processes_path
        end

        def copy
          authorize! :create, Decidim::ParticipatoryProcess
        end

        private

        def current_participatory_process
          @current_participatory_process ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_participatory_process

        def collection
          @collection ||= Decidim::ParticipatoryProcessesWithUserRole.for(current_user)
        end

        def ability_context
          super.merge(current_participatory_space: current_participatory_process)
        end

        def participatory_process_params
          {
            id: params[:slug],
            hero_image: current_participatory_process.hero_image,
            banner_image: current_participatory_process.banner_image
          }.merge(params[:participatory_process].to_unsafe_h)
        end

        def current_participatory_space_manifest_name
          :participatory_processes
        end
      end
    end
  end
end
