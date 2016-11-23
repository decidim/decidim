# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the attachments for a participatory
    # process.
    #
    class ParticipatoryProcessAttachmentsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, ParticipatoryProcessAttachment
      end

      def new
        authorize! :create, ParticipatoryProcessAttachment
        @form = form(ParticipatoryProcessAttachmentForm).instance
      end

      def create
        authorize! :create, ParticipatoryProcessAttachment
        @form = form(ParticipatoryProcessAttachmentForm).from_params(params)

        CreateParticipatoryProcessAttachment.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_attachments.create.success", scope: "decidim.admin")
            redirect_to participatory_process_attachments_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_attachments.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        @participatory_process_attachment = collection.find(params[:id])
        authorize! :update, @participatory_process_attachment
        @form = form(ParticipatoryProcessAttachmentForm).from_model(@participatory_process_attachment)
      end

      def update
        @participatory_process_attachment = collection.find(params[:id])
        authorize! :update, @participatory_process_attachment
        @form = form(ParticipatoryProcessAttachmentForm).from_params(params)

        UpdateParticipatoryProcessAttachment.call(@participatory_process_attachment, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_process_attachments.update.success", scope: "decidim.admin")
            redirect_to participatory_process_attachments_path(participatory_process)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_process_attachments.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        @participatory_process_attachment = collection.find(params[:id])
        authorize! :read, @participatory_process_attachment
      end

      def destroy
        @participatory_process_attachment = collection.find(params[:id])
        authorize! :destroy, @participatory_process_attachment
        @participatory_process_attachment.destroy!

        flash[:notice] = I18n.t("participatory_process_attachments.destroy.success", scope: "decidim.admin")

        redirect_to participatory_process_attachments_path(@participatory_process_attachment.participatory_process)
      end

      private

      def collection
        @collection ||= participatory_process.attachments
      end
    end
  end
end
