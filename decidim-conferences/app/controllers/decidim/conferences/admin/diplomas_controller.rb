# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows an admin to manage Conference Diploma configuration
      class DiplomasController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        # helper_method :current_conference, :current_participatory_space

        def edit
          enforce_permission_to :update, :conference, conference: current_conference

          @form = form(DiplomaForm).from_model(current_conference)
        end

        def update
          enforce_permission_to :update, :conference, conference: current_conference

          @form = form(DiplomaForm).from_params(diploma_params).with_context(conference: current_conference)

          UpdateDiploma.call(@form, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences.update.success", scope: "decidim.admin")
              redirect_to edit_conference_diploma_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/conference"
            end
          end
        end

        def send_diplomas
          raise
        end

        private

        def diploma_params
          {
            id: params[:slug],
            signature: current_conference.signature,
            main_logo: current_conference.main_logo
          }.merge(params[:conference].to_unsafe_h)
        end
      end
    end
  end
end
