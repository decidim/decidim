# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      require "csv"

      # Controller used to manage the initiatives
      class InitiativesController < Decidim::Initiatives::Admin::ApplicationController
        include Decidim::Initiatives::NeedsInitiative
        include Decidim::Initiatives::SingleInitiativeType
        include Decidim::Initiatives::TypeSelectorOptions
        include Decidim::Initiatives::Admin::Filterable
        include Decidim::Admin::ParticipatorySpaceAdminBreadcrumb

        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper Decidim::Initiatives::InitiativeHelper
        helper Decidim::Initiatives::SignatureTypeOptionsHelper

        helper_method :show_initiative_type_callout?

        # GET /admin/initiatives
        def index
          enforce_permission_to :list, :initiative
          @initiatives = filtered_collection
        end

        # GET /admin/initiatives/:id/edit
        def edit
          enforce_permission_to :edit, :initiative, initiative: current_initiative

          form_attachment_model = form(AttachmentForm).from_model(current_initiative.attachments.first)
          @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                  .from_model(
                    current_initiative,
                    initiative: current_initiative
                  )
          @form.attachment = form_attachment_model

          render layout: "decidim/admin/initiative"
        end

        # PUT /admin/initiatives/:id
        def update
          enforce_permission_to :update, :initiative, initiative: current_initiative

          params[:id] = params[:slug]
          @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                  .from_params(params, initiative: current_initiative)

          Decidim::Initiatives::Admin::UpdateInitiative.call(@form, current_initiative) do
            on(:ok) do |initiative|
              flash[:notice] = I18n.t("initiatives.update.success", scope: "decidim.initiatives.admin")
              redirect_to edit_initiative_path(initiative)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("initiatives.update.error", scope: "decidim.initiatives.admin")
              render :edit, layout: "decidim/admin/initiative"
            end
          end
        end

        # POST /admin/initiatives/:id/publish
        def publish
          enforce_permission_to :publish, :initiative, initiative: current_initiative

          PublishInitiative.call(current_initiative, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.publish.success", scope: "decidim.initiatives.admin")
              redirect_to decidim_admin_initiatives.edit_initiative_path(current_initiative)
            end
          end
        end

        # DELETE /admin/initiatives/:id/unpublish
        def unpublish
          enforce_permission_to :unpublish, :initiative, initiative: current_initiative

          UnpublishInitiative.call(current_initiative, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.unpublish.success", scope: "decidim.initiatives.admin")
              redirect_to decidim_admin_initiatives.edit_initiative_path(current_initiative)
            end
          end
        end

        # DELETE /admin/initiatives/:id/discard
        def discard
          enforce_permission_to :discard, :initiative, initiative: current_initiative
          DiscardInitiative.call(current_initiative, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.discard.success", scope: "decidim.initiatives.admin")
              redirect_to decidim_admin_initiatives.edit_initiative_path(current_initiative)
            end
          end
        end

        # POST /admin/initiatives/:id/accept
        def accept
          enforce_permission_to :accept, :initiative, initiative: current_initiative
          AcceptInitiative.call(current_initiative, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.accept.success", scope: "decidim.initiatives.admin")
              redirect_to decidim_admin_initiatives.edit_initiative_path(current_initiative)
            end
          end
        end

        # DELETE /admin/initiatives/:id/reject
        def reject
          enforce_permission_to :reject, :initiative, initiative: current_initiative
          RejectInitiative.call(current_initiative, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.reject.success", scope: "decidim.initiatives.admin")
              redirect_to decidim_admin_initiatives.edit_initiative_path(current_initiative)
            end
          end
        end

        # GET /admin/initiatives/:id/send_to_technical_validation
        def send_to_technical_validation
          enforce_permission_to :send_to_technical_validation, :initiative, initiative: current_initiative

          SendInitiativeToTechnicalValidation.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to EngineRouter.main_proxy(current_initiative).initiatives_path(initiative_slug: nil), flash: {
                notice: I18n.t(
                  "success",
                  scope: "decidim.initiatives.admin.initiatives.edit"
                )
              }
            end
          end
        end

        # GET /admin/initiatives/export
        def export
          enforce_permission_to :export, :initiatives

          Decidim::Initiatives::ExportInitiativesJob.perform_later(
            current_user,
            current_organization,
            params[:format] || default_format,
            params[:collection_ids].presence&.map(&:to_i)
          )

          flash[:notice] = t("decidim.admin.exports.notice")

          redirect_back(fallback_location: initiatives_path)
        end

        # GET /admin/initiatives/:id/export_votes
        def export_votes
          enforce_permission_to :export_votes, :initiative, initiative: current_initiative

          votes = current_initiative.votes.map(&:sha1)
          csv_data = CSV.generate(headers: false) do |csv|
            votes.each do |sha1|
              csv << [sha1]
            end
          end

          respond_to do |format|
            format.csv { send_data csv_data, file_name: "votes.csv" }
          end
        end

        # GET /admin/initiatives/:id/export_pdf_signatures.pdf
        def export_pdf_signatures
          enforce_permission_to :export_pdf_signatures, :initiative, initiative: current_initiative

          @votes = current_initiative.votes

          serializer = Decidim::Forms::UserResponsesSerializer
          pdf_export = Decidim::Exporters::InitiativeVotesPDF.new(@votes, current_initiative, serializer).export

          output = if pdf_signature_service
                     pdf_signature_service.new(pdf: pdf_export.read).signed_pdf
                   else
                     pdf_export.read
                   end

          respond_to do |format|
            format.pdf do
              send_data(output, filename: "votes_#{current_initiative.id}.pdf", type: "application/pdf")
            end
          end
        end

        private

        def show_initiative_type_callout?
          Decidim::InitiativesType.where(organization: current_organization).none?
        end

        def collection
          @collection ||= ManageableInitiatives.for(current_user)
        end

        def pdf_signature_service
          @pdf_signature_service ||= Decidim.pdf_signature_service.to_s.safe_constantize
        end

        def default_format
          "json"
        end
      end
    end
  end
end
