# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process groups.
      #
      class ParticipatoryProcessGroupsController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::TranslatableAttributes

        helper ProcessesForSelectHelper

        before_action :set_controller_breadcrumb
        add_breadcrumb_item_from_menu :admin_participatory_processes_menu

        helper_method :collection, :participatory_process_group

        def index
          enforce_permission_to :read, :process_group
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
              redirect_to edit_participatory_process_group_path(participatory_process_group)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes_group.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @item = collection.find(params[:id])
          enforce_permission_to :update, :process_group, process_group: @item
          @form = form(ParticipatoryProcessGroupForm).from_model(@item)
          render layout: "decidim/admin/participatory_process_group"
        end

        def update
          @participatory_process_group = collection.find(params[:id])
          enforce_permission_to :update, :process_group, process_group: @participatory_process_group
          @form = form(ParticipatoryProcessGroupForm).from_params(params)

          UpdateParticipatoryProcessGroup.call(@form, @participatory_process_group) do
            on(:ok) do |participatory_process_group|
              flash[:notice] = I18n.t("participatory_process_groups.update.success", scope: "decidim.admin")
              redirect_to edit_participatory_process_group_path(participatory_process_group)
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

          Decidim::Commands::DestroyResource.call(@participatory_process_group, current_user) do
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

        def set_controller_breadcrumb
          return unless collection.exists?(params[:id])

          controller_breadcrumb_items.append(
            label: translated_attribute(participatory_process_group.title),
            url: edit_participatory_process_group_path(participatory_process_group),
            active: true,
            resource: participatory_process_group
          )
        end

        def participatory_process_group
          @participatory_process_group ||= collection.find(params[:id])
        end

        def collection
          @collection ||= OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end
      end
    end
  end
end
