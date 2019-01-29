# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      require "csv"

      # Controller used to manage the initiatives
      class InitiativesController < Decidim::Initiatives::Admin::ApplicationController
        include Decidim::Initiatives::NeedsInitiative
        include Decidim::Initiatives::TypeSelectorOptions

        helper Decidim::Initiatives::InitiativeHelper
        helper Decidim::Initiatives::CreateInitiativeHelper

        # GET /admin/initiatives
        def index
          enforce_permission_to :list, :initiative

          @query = params[:q]
          @state = params[:state]
          @initiatives = ManageableInitiatives
                         .for(
                           current_organization,
                           current_user,
                           @query,
                           @state
                         )
                         .page(params[:page])
                         .per(15)
        end

        # GET /admin/initiatives/:id
        def show
          enforce_permission_to :read, :initiative, initiative: current_initiative
        end

        # GET /admin/initiatives/:id/edit
        def edit
          enforce_permission_to :edit, :initiative, initiative: current_initiative
          @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                  .from_model(
                    current_initiative,
                    initiative: current_initiative
                  )

          render layout: "decidim/admin/initiative"
        end

        # PUT /admin/initiatives/:id
        def update
          enforce_permission_to :update, :initiative, initiative: current_initiative

          params[:id] = params[:slug]
          @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                  .from_params(params, initiative: current_initiative)

          UpdateInitiative.call(current_initiative, @form, current_user) do
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
              redirect_to decidim_admin_initiatives.initiatives_path
            end
          end
        end

        # DELETE /admin/initiatives/:id/unpublish
        def unpublish
          enforce_permission_to :unpublish, :initiative, initiative: current_initiative

          UnpublishInitiative.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to decidim_admin_initiatives.initiatives_path
            end
          end
        end

        # DELETE /admin/initiatives/:id/discard
        def discard
          enforce_permission_to :discard, :initiative, initiative: current_initiative
          current_initiative.discarded!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # POST /admin/initiatives/:id/accept
        def accept
          enforce_permission_to :accept, :initiative, initiative: current_initiative
          current_initiative.accepted!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # DELETE /admin/initiatives/:id/reject
        def reject
          enforce_permission_to :reject, :initiative, initiative: current_initiative
          current_initiative.rejected!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # GET /admin/initiatives/:id/send_to_technical_validation
        def send_to_technical_validation
          enforce_permission_to :send_to_technical_validation, :initiative, initiative: current_initiative

          SendInitiativeToTechnicalValidation.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to edit_initiative_path(current_initiative), flash: {
                notice: I18n.t(
                  "success",
                  scope: %w(decidim initiatives admin initiatives edit)
                )
              }
            end
          end
        end

        # GET /admin/initiatives/:id/export_votes
        def export_votes
          enforce_permission_to :export_votes, :initiative, initiative: current_initiative

          votes = current_initiative.votes.votes.map(&:sha1)
          csv_data = CSV.generate(headers: false) do |csv|
            votes.each do |sha1|
              csv << [sha1]
            end
          end

          respond_to do |format|
            format.csv { send_data csv_data, file_name: "votes.csv" }
          end
        end

        def export_pdf_signatures
          enforce_permission_to :export_pdf_signatures, :initiative, initiative: current_initiative

          @votes = current_initiative.votes.votes

          respond_to do |format|
            format.pdf do
              render pdf: "votes_#{current_initiative.id}", layout: "decidim/admin/initiatives_votes"
            end
          end
        end
      end
    end
  end
end
