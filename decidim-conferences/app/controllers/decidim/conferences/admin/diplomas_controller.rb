# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows an admin to manage Conference Diploma configuration
      class DiplomasController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        add_breadcrumb_item_from_menu :conferences_admin_registrations_menu

        def edit
          enforce_permission_to :update, :conference, conference: current_conference

          @form = form(DiplomaForm).from_model(current_conference)
        end

        def update
          enforce_permission_to :update, :conference, conference: current_conference

          @form = form(DiplomaForm).from_params(diploma_params).with_context(conference: current_conference, current_organization:)

          UpdateDiploma.call(@form, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences.update.success", scope: "decidim.admin")
              redirect_to edit_conference_diploma_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def preview_diploma
          @user = Decidim::User.find params[:user_id]
          @conference = Decidim::Conference.find_by_slug params[:conference_slug]

          render "decidim/conferences/admin/send_conference_diploma_mailer/diploma_user", layout: "decidim/diploma"
        end

        def send_diplomas
          enforce_permission_to :send_diplomas, :conference, conference: current_conference

          SendConferenceDiplomas.call(current_conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("send_diploma.success", scope: "decidim.conferences.admin")
              redirect_to edit_conference_diploma_path(current_conference)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("send_diploma.error", scope: "decidim.conferences.admin")
              redirect_to edit_conference_diploma_path(current_conference)
            end
          end
        end

        private

        def diploma_params
          {
            id: params[:slug]
          }.merge(params[:conference].to_unsafe_h)
        end
      end
    end
  end
end
