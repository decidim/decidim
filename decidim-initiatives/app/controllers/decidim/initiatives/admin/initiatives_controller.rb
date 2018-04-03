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
          authorize! :list, Decidim::Initiative

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
          authorize! :read, current_initiative
        end

        # GET /admin/initiatives/:id/edit
        def edit
          authorize! :edit, current_initiative
          @form = form(Decidim::Initiatives::Admin::InitiativeForm)
                  .from_model(
                    current_initiative,
                    initiative: current_initiative
                  )

          render layout: "decidim/admin/initiative"
        end

        # PUT /admin/initiatives/:id
        def update
          authorize! :update, current_initiative

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
          authorize! :publish, current_initiative

          PublishInitiative.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to decidim_admin_initiatives.initiatives_path
            end
          end
        end

        # DELETE /admin/initiatives/:id/unpublish
        def unpublish
          authorize! :unpublish, current_initiative

          UnpublishInitiative.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to decidim_admin_initiatives.initiatives_path
            end
          end
        end

        # DELETE /admin/initiatives/:id/discard
        def discard
          authorize! :discard, current_initiative
          current_initiative.discarded!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # POST /admin/initiatives/:id/accept
        def accept
          authorize! :accept, current_initiative
          current_initiative.accepted!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # DELETE /admin/initiatives/:id/reject
        def reject
          authorize! :reject, current_initiative
          current_initiative.rejected!
          redirect_to decidim_admin_initiatives.initiatives_path
        end

        # GET /admin/initiatives/:id/send_to_technical_validation
        def send_to_technical_validation
          authorize! :send_to_technical_validation, current_initiative

          SendInitiativeToTechnicalValidation.call(current_initiative, current_user) do
            on(:ok) do
              redirect_to edit_initiative_path(current_initiative), flash: {
                notice: I18n.t(
                  ".success",
                  scope: %w(decidim initiatives admin initiatives edit)
                )
              }
            end
          end
        end

        # GET /admin/initiatives/:id/export_votes
        def export_votes
          authorize! :export_votes, current_initiative

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
      end
    end
  end
end
