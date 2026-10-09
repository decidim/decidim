# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process phases.
      #
      class ParticipatoryProcessPhasesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        before_action :find_participatory_process_phase, except: [:index, :new, :create]
        before_action :set_controller_breadcrumb

        def index
          enforce_permission_to :read, :process_phase
        end

        def new
          enforce_permission_to :create, :process_phase
          @form = form(ParticipatoryProcessPhaseForm).instance
        end

        def create
          enforce_permission_to :create, :process_phase
          @form = form(ParticipatoryProcessPhaseForm).from_params(params)

          CreateParticipatoryProcessPhase.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_phases.create.success", scope: "decidim.admin")
              redirect_to participatory_process_phases_path(current_participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_phases.create.error", scope: "decidim.admin")
              render :new, status: :unprocessable_content
            end
          end
        end

        def edit
          enforce_permission_to :update, :process_phase, process_phase: @participatory_process_phase
          @form = form(ParticipatoryProcessPhaseForm).from_model(@participatory_process_phase)
        end

        def update
          enforce_permission_to :update, :process_phase, process_phase: @participatory_process_phase
          @form = form(ParticipatoryProcessPhaseForm).from_params(params)

          UpdateParticipatoryProcessPhase.call(@form, @participatory_process_phase) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_phases.update.success", scope: "decidim.admin")
              redirect_to participatory_process_phases_path(current_participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_phases.update.error", scope: "decidim.admin")
              render :edit, status: :unprocessable_content
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :process_phase, process_phase: @participatory_process_phase

          DestroyParticipatoryProcessPhase.call(@participatory_process_phase, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_phases.destroy.success", scope: "decidim.admin")
              redirect_to participatory_process_phases_path(current_participatory_process)
            end

            on(:invalid) do |reason|
              flash[:alert] = I18n.t("participatory_process_phases.destroy.error.#{reason}", scope: "decidim.admin")
              redirect_to participatory_process_phases_path(current_participatory_process)
            end
          end
        end

        private

        def collection
          @collection ||= current_participatory_process.phases
        end

        def find_participatory_process_phase
          @participatory_process_phase = collection.find(params.expect(:id))
        end

        def set_controller_breadcrumb
          return if @participatory_process_phase.blank?

          controller_breadcrumb_items << {
            label: translated_attribute(@participatory_process_phase.title),
            active: true
          }
        end
      end
    end
  end
end
