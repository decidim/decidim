# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meeting inscriptions from a Participatory Process
      class InscriptionsController < Admin::ApplicationController
        def edit
          @form = MeetingInscriptionsForm.from_model(meeting)
        end

        def update
          @form = MeetingInscriptionsForm.from_params(params)

          UpdateInscriptions.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("inscriptions.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("inscriptions.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(feature: current_feature).find(params[:meeting_id])
        end
      end
    end
  end
end
