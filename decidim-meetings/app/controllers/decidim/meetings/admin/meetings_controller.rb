# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meetings from a Participatory Process
      class MeetingsController < Admin::ApplicationController
        include Decidim::Meetings::Admin::Filterable

        helper_method :blank_service

        def new
          enforce_permission_to :create, :meeting

          @form = meeting_form.instance
        end

        def create
          enforce_permission_to :create, :meeting

          @form = meeting_form.from_params(params, current_component:)

          Decidim::Meetings::Admin::CreateMeeting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.create.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.create.invalid", scope: "decidim.meetings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = meeting_form.from_model(meeting)
        end

        def update
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = meeting_form.from_params(params, current_component:)

          Decidim::Meetings::Admin::UpdateMeeting.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :meeting, meeting: meeting

          Decidim::Meetings::Admin::DestroyMeeting.call(meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.destroy.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do |proposals_count|
              flash.now[:alert] = I18n.t(
                "meetings.destroy.invalid.proposals_count",
                count: proposals_count,
                scope: "decidim.meetings.admin"
              )

              render action: "index"
            end
          end
        end

        def publish
          enforce_permission_to :update, :meeting, meeting: meeting

          Decidim::Meetings::Admin::PublishMeeting.call(meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.publish.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.publish.invalid", scope: "decidim.meetings.admin")
              render action: "index"
            end
          end
        end

        def unpublish
          enforce_permission_to :update, :meeting, meeting: meeting

          Decidim::Meetings::Admin::UnpublishMeeting.call(meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.unpublish.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.unpublish.invalid", scope: "decidim.meetings.admin")
              render action: "index"
            end
          end
        end

        private

        def meetings
          @meetings ||= filtered_collection
        end

        def meeting
          @meeting ||= meetings.find(params[:id])
        end

        def collection
          @collection ||= Meeting.where(component: current_component).published.not_hidden
        end

        def meeting_form
          form(Decidim::Meetings::Admin::MeetingForm)
        end

        def blank_service
          @blank_service ||= Admin::MeetingServiceForm.new
        end
      end
    end
  end
end
