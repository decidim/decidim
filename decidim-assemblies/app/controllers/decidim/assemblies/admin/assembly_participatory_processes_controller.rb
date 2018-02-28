# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly participatory process.
      #
      class AssemblyParticipatoryProcessesController < Decidim::Admin::ApplicationController
        include Decidim::Assemblies::Admin::AssemblyParticipatoryProcessesHelper

        helper_method :current_assembly, :current_participatory_space, :current_assembly_participatory_process
        layout "decidim/admin/assembly"

        def index
          authorize! :index, Decidim::AssemblyParticipatoryProcess
          @assembly_participatory_processes = current_assembly.assembly_participatory_processes.order(:id)
        end

        def new
          authorize! :new, Decidim::AssemblyParticipatoryProcess
          @form = form(AssemblyParticipatoryProcessForm).instance
        end

        def create
          authorize! :new, Decidim::AssemblyParticipatoryProcess
          @form = form(AssemblyParticipatoryProcessForm).from_params(params)

          CreateAssemblyParticipatoryProcess.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_participatory_processes.create.success", scope: "decidim.admin")
              redirect_to assembly_participatory_processes_path(current_assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_participatory_processes.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          authorize! :update, current_assembly_participatory_process
          @form = form(AssemblyParticipatoryProcessForm).from_model(current_assembly_participatory_process)
        end

        def update
          authorize! :update, current_assembly_participatory_process
          @form = form(AssemblyParticipatoryProcessForm).from_params(params)

          UpdateAssemblyParticipatoryProcess.call(current_assembly_participatory_process, @form) do
            on(:ok) do |_assembly|
              flash[:notice] = I18n.t("assembly_participatory_processes.update.success", scope: "decidim.admin")
              redirect_to assembly_participatory_processes_path(current_assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_participatory_processes.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          authorize! :destroy, current_assembly_participatory_process
          current_assembly_participatory_process.destroy!

          flash[:notice] = I18n.t("assembly_participatory_processes.destroy.success", scope: "decidim.admin")

          redirect_to assembly_participatory_processes_path(current_assembly)
        end

        private

        def current_assembly
          @current_assembly ||= collection.where(slug: params[:assembly_slug]).or(
            collection.where(id: params[:assembly_slug])
          ).first
        end

        alias current_participatory_space current_assembly

        def collection
          @collection ||= OrganizationAssemblies.new(current_user.organization).query
        end

        def current_assembly_participatory_process
          @current_assembly_participatory_process ||= current_assembly.assembly_participatory_processes.find_by(id: params[:id])
        end
      end
    end
  end
end
