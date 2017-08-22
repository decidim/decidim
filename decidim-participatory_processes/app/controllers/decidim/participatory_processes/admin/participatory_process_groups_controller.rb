# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process groups.
      #
      class ParticipatoryProcessGroupsController < Decidim::Admin::ApplicationController
        helper ProcessesForSelectHelper

        helper_method :collection, :participatory_process_group

        def index
          authorize! :read, ParticipatoryProcessGroup
        end

        def show
          authorize! :read, participatory_process_group
        end

        def new
          authorize! :new, Decidim::ParticipatoryProcessGroup
          @form = form(ParticipatoryProcessGroupForm).instance
        end

        def create
          authorize! :new, Decidim::ParticipatoryProcessGroup
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
          authorize! :update, @participatory_process_group
          @form = form(ParticipatoryProcessGroupForm).from_model(@participatory_process_group)
        end

        def update
          @participatory_process_group = collection.find(params[:id])
          authorize! :update, @participatory_process_group
          @form = form(ParticipatoryProcessGroupForm).from_params(params)

          UpdateParticipatoryProcessGroup.call(@participatory_process_group, @form) do
            on(:ok) do |participatory_process_group|
              flash[:notice] = I18n.t("participatory_process_groups.update.success", scope: "decidim.admin")
              redirect_to participatory_process_group_path(participatory_process_group)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_groups.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @participatory_process_group = collection.find(params[:id])
          authorize! :destroy, @participatory_process_group
          @participatory_process_group.destroy!

          flash[:notice] = I18n.t("participatory_process_groups.destroy.success", scope: "decidim.admin")

          redirect_to participatory_process_groups_path
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
