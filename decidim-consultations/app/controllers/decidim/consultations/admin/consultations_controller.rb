# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller in charge of managing consultation related requests
      class ConsultationsController < Decidim::Consultations::Admin::ApplicationController
        helper_method :current_consultation, :current_participatory_space

        # GET /admin/consultations
        def index
          authorize! :index, Decidim::Consultation
          @consultations = collection
        end

        # GET /admin/consultations/new
        def new
          authorize! :new, Consultation
          @form = consultation_form.instance
        end

        # POST /admin/consultations
        def create
          authorize! :create, Consultation
          @form = consultation_form.from_params(params)

          CreateConsultation.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("consultations.create.success", scope: "decidim.admin")
              redirect_to consultations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("consultations.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        # GET /admin/consultations/:slug/edit
        def edit
          authorize! :edit, current_consultation
          @form = consultation_form.from_model(current_consultation)
          render layout: "decidim/admin/consultation"
        end

        # PUT /admin/initiatives/:id
        def update
          authorize! :update, current_consultation

          @form = consultation_form
                  .from_params(params.except(:slug), consultation_id: current_consultation.id)

          UpdateConsultation.call(current_consultation, @form) do
            on(:ok) do |consultation|
              flash[:notice] = I18n.t("consultations.update.success", scope: "decidim.admin")
              redirect_to edit_consultation_path(consultation)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("consultations.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/consultation"
            end
          end
        end

        def destroy
          authorize! :destroy, current_consultation
          current_consultation.destroy!

          flash[:notice] = I18n.t("consultations.destroy.success", scope: "decidim.admin")

          redirect_to consultations_path
        end

        private

        def current_consultation
          @current_consultation ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_consultation

        def collection
          @collection ||= OrganizationConsultations.new(current_user.organization).query
        end

        def ability_context
          super.merge(current_consultation: current_consultation)
        end

        def consultation_form
          form(ConsultationForm)
        end

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
