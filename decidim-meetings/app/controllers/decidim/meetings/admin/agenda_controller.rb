# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing the agendas for the given meeting
      #
      class AgendaController < Admin::ApplicationController
        helper_method :meeting, :agenda, :blank_agenda_item, :blank_agenda_item_child

        def new
          enforce_permission_to :create, :agenda, meeting: meeting

          @form = form(MeetingAgendaForm).instance
        end

        def create
          enforce_permission_to :create, :agenda, meeting: meeting

          @form = form(MeetingAgendaForm).from_params(params, meeting:)

          CreateAgenda.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("agenda.create.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("agenda.create.invalid", scope: "decidim.meetings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :agenda, agenda: agenda, meeting: meeting

          @form = form(MeetingAgendaForm).from_model(agenda)
        end

        def update
          enforce_permission_to :update, :agenda, agenda: agenda, meeting: meeting

          @form = form(MeetingAgendaForm).from_params(params, meeting:)

          UpdateAgenda.call(@form, agenda) do
            on(:ok) do
              flash[:notice] = I18n.t("agenda.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("agenda.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def agenda
          @agenda ||= meeting.agenda
        end

        def blank_agenda_item
          @blank_agenda_item ||= Admin::MeetingAgendaItemsForm.new
        end
      end
    end
  end
end
