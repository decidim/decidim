# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource
      include Filterable
      include Flaggable
      include Withdrawable
      include FormFactory
      include Paginable

      helper Decidim::WidgetUrlsHelper
      helper Decidim::ResourceVersionsHelper

      helper_method :meetings, :meeting, :registration, :search

      def new
        enforce_permission_to :create, :meeting

        @form = meeting_form.instance
      end

      def create
        enforce_permission_to :create, :meeting

        @form = meeting_form.from_params(params, current_component: current_component)

        CreateMeeting.call(@form) do
          on(:ok) do |meeting|
            flash[:notice] = I18n.t("meetings.create.success", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("meetings.create.invalid", scope: "decidim.meetings")
            render action: "new"
          end
        end
      end

      def index
        return unless search.results.blank? && params.dig("filter", "date") != %w(past)

        @past_meetings = search_klass.new(search_params.merge(date: %w(past)))

        if @past_meetings.results.present?
          params[:filter] ||= {}
          params[:filter][:date] = %w(past)
          @forced_past_meetings = true
          @search = @past_meetings
        end
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless meeting

        return if meeting.current_user_can_visit_meeting?(current_user)

        flash[:alert] = I18n.t("meeting.not_allowed", scope: "decidim.meetings")
        redirect_to(ResourceLocatorPresenter.new(meeting).index)
      end

      def edit
        enforce_permission_to :update, :meeting, meeting: meeting

        @form = meeting_form.from_model(meeting)
      end

      def update
        enforce_permission_to :update, :meeting, meeting: meeting

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

      def withdraw
        enforce_permission_to :withdraw, :meeting, meeting: meeting

        WithdrawMeeting.call(@meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("meetings.withdraw.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@meeting).path
          end
          on(:invalid) do
            flash[:alert] = I18n.t("meetings.withdraw.error", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@meeting).path
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.not_hidden.where(component: current_component).find_by(id: params[:id])
      end

      def meetings
        @meetings ||= paginate(search.results.order(start_time: :desc))
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
          search_text: "",
          date: %w(upcoming),
          activity: "all",
          scope_id: default_filter_scope_params,
          category_id: default_filter_category_params,
          state: nil,
          origin: default_filter_origin_params,
          type: default_filter_type_params
        }
      end
    end
  end
end
