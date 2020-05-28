# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource
      include FormFactory
      include Paginable
      helper Decidim::WidgetUrlsHelper

      helper_method :meetings, :meeting, :registration, :search

      def new
        # todo
        # enforce_permission_to :create, :meeting

        @form = meeting_form.instance
      end

      def create
        # todo
        # enforce_permission_to :create, :meeting

        @form = meeting_form.from_params(params, current_component: current_component)

        CreateMeeting.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("meetings.create.success", scope: "decidim.meetings")
            redirect_to meetings_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("meetings.create.invalid", scope: "decidim.meetings")
            render action: "new"
          end
        end
      end

      def index
        return unless search.results.blank? && params.dig("filter", "date") != "past"

        @past_meetings = search_klass.new(search_params.merge(date: "past"))

        if @past_meetings.results.present?
          params[:filter] ||= {}
          params[:filter][:date] = "past"
          @forced_past_meetings = true
          @search = @past_meetings
        end
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless meeting

        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")

        return if meeting.current_user_can_visit_meeting?(current_user)

        flash[:alert] = I18n.t("meeting.not_allowed", scope: "decidim.meetings")
        redirect_to action: "index"
      end

      def edit
        # todo
        # enforce_permission_to :edit, :meeting, meeting: meeting

        @form = meeting_form.from_model(meeting)
      end

      def update
        # todo
        # enforce_permission_to :edit, :meeting, meeting: meeting

        @form = meeting_form.from_params(params)

        UpdateMeeting.call(@form, current_user, meeting) do
          on(:ok) do |meeting|
            flash[:notice] = I18n.t("meetings.update.success", scope: "decidim.meetings")
            redirect_to Decidim::ResourceLocatorPresenter.new(meeting).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("meetings.update.invalid", scope: "decidim.meetings")
            render :edit
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.not_hidden.where(component: current_component).find(params[:id])
      end

      def meetings
        @meetings ||= paginate(search.results.not_hidden)
      end

      def registration
        @registration ||= meeting.registrations.find_by(user: current_user)
      end

      def search_klass
        MeetingSearch
      end

      def meeting_form
        form(Decidim::Meetings::MeetingForm)
      end

      def default_filter_params
        {
          date: "upcoming",
          search_text: "",
          scope_id: "",
          category_id: ""
        }
      end

      def default_search_params
        {
          scope: Meeting.visible_meeting_for(current_user)
        }
      end

      def context_params
        { component: current_component, organization: current_organization }
      end
    end
  end
end
