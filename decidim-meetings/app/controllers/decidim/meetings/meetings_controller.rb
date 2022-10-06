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
      helper Decidim::ShortLinkHelper

      helper_method :meetings, :meeting, :registration, :search

      def new
        enforce_permission_to :create, :meeting

        @form = meeting_form.instance
      end

      def create
        enforce_permission_to :create, :meeting

        @form = meeting_form.from_params(params, current_component:)

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
        return unless search.result.blank? && params.dig("filter", "date") != %w(past)

        @past_meetings ||= search_with(filter_params.merge(with_any_date: %w(past)))

        if @past_meetings.result.present?
          params[:filter] ||= {}
          params[:filter][:with_any_date] = %w(past)
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
        is_past_meetings = params.dig("filter", "with_any_date")&.include?("past")
        @meetings ||= paginate(search.result.order(start_time: is_past_meetings ? :desc : :asc))
      end

      def registration
        @registration ||= meeting.registrations.find_by(user: current_user)
      end

      def search_collection
        Meeting.where(component: current_component).published.not_hidden.visible_for(current_user).with_availability(
          filter_params[:with_availability]
        ).includes(
          :component,
          attachments: :file_attachment
        )
      end

      def meeting_form
        form(Decidim::Meetings::MeetingForm)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_date: "upcoming",
          activity: "all",
          with_availability: "",
          with_any_scope: default_filter_scope_params,
          with_any_category: default_filter_category_params,
          with_any_state: nil,
          with_any_origin: default_filter_origin_params,
          with_any_type: default_filter_type_params
        }
      end
    end
  end
end
