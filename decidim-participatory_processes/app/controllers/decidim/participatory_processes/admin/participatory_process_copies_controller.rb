# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory processes.
      #
      class ParticipatoryProcessCopiesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        before_action :set_copies_breadcrumb_item

        def new
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessCopyForm).from_model(current_participatory_process)
        end

        def create
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessCopyForm).from_params(params)

          CopyParticipatoryProcess.call(@form, current_participatory_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_processes_copies.create.success", scope: "decidim.admin")
              redirect_to participatory_processes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes_copies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        private

        def set_copies_breadcrumb_item
          context_breadcrumb_items << {
            label: t("title", scope: "decidim.admin.participatory_process_copies.new"),
            url: new_participatory_process_copy_path(current_participatory_process),
            active: true
          }
        end
      end
    end
  end
end
