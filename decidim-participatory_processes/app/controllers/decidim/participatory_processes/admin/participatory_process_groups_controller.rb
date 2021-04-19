# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process groups.
      #
      class ParticipatoryProcessGroupsController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        helper ProcessesForSelectHelper

        helper_method :collection, :participatory_process_group

        def index
          enforce_permission_to :read, :process_group
        end

        def show
          enforce_permission_to :read, :process_group, process_group: participatory_process_group
          render layout: "decidim/admin/participatory_process_group"
        end

        def new
          enforce_permission_to :create, :process_group
          @form = form(ParticipatoryProcessGroupForm).instance
        end

        def create
          enforce_permission_to :create, :process_group
          @form = form(ParticipatoryProcessGroupForm).from_params(params)

          CreateParticipatoryProcessGroup.call(@form) do
            on(:ok) do |participatory_process_group|
              flash[:notice] = I18n.t("participatory_processes_group.create.success", scope: "decidim.admin")
              redirect_to participatory_process_group_path(participatory_process_group)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes_group.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @participatory_process_group = collection.find(params[:id])
          enforce_permission_to :update, :process_group, process_group: @participatory_process_group
          @form = form(ParticipatoryProcessGroupForm).from_model(@participatory_process_group)
          render layout: "decidim/admin/participatory_process_group"
        end

        def update
          @participatory_process_group = collection.find(params[:id])
          enforce_permission_to :update, :process_group, process_group: @participatory_process_group
          @form = form(ParticipatoryProcessGroupForm).from_params(params)

          UpdateParticipatoryProcessGroup.call(@participatory_process_group, @form) do
            on(:ok) do |participatory_process_group|
              flash[:notice] = I18n.t("participatory_process_groups.update.success", scope: "decidim.admin")
              redirect_to participatory_process_group_path(participatory_process_group)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_groups.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/participatory_process_group"
            end
          end
        end

        def destroy
          @participatory_process_group = collection.find(params[:id])
          enforce_permission_to :destroy, :process_group, process_group: @participatory_process_group

          DestroyParticipatoryProcessGroup.call(@participatory_process_group, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_groups.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_groups.destroy.error", scope: "decidim.admin")
              render :index
            end
          end
        end

        private

        def participatory_process_group
          @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(params[:id])
        end

        def collection
          @collection ||=
            OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end
      end
    end
  end
end
