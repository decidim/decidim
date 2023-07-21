# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource
      include Filterable
      include ComponentFilterable
      include Flaggable
      include Withdrawable
      include FormFactory
      include Paginable

      helper Decidim::ResourceVersionsHelper
      helper Decidim::ShortLinkHelper
      include Decidim::AttachmentsHelper

      helper_method :meetings, :meeting, :registration, :search, :nav_paths, :tab_panel_items

      redesign active: true

      before_action :add_addtional_csp_directives, only: [:show]

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

      def year_calendar
        @filter_options = {
          # REDESIGN_PENDING: This variable must be set
          date: !@forced_past_meetings,
          type: true,
          scopes: current_component.has_subscopes?,
          categories: current_component.categories.any?,
          origin: component_settings.creation_enabled_for_participants?,
          space_type: false,
          activity: current_user.present?
        }
        @search_variable = :search_text_cont
        @year = (params[:year] || Date.current.year).to_i
        @year_path = proc { |year| year_calendar_meetings_path(year) }
        render template: "decidim/meetings/directory/meetings/year_calendar"
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless meeting

        return if meeting.current_user_can_visit_meeting?(current_user)

        flash[:alert] = I18n.t("meeting.not_allowed", scope: "decidim.meetings")
        redirect_to(ResourceLocatorPresenter.new(meeting).index)
      end

      def edit
        enforce_permission_to(:update, :meeting, meeting:)

        @form = meeting_form.from_model(meeting)
      end

      def update
        enforce_permission_to(:update, :meeting, meeting:)

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
        enforce_permission_to(:withdraw, :meeting, meeting:)

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

      def next_meeting
        return if search_collection.size < 2

        search_collection.order(:start_time, :id).where(
          Decidim::Meetings::Meeting.arel_table[:start_time].gt(meeting.start_time).or(
            Decidim::Meetings::Meeting.arel_table[:start_time].eq(meeting.start_time).and(
              Decidim::Meetings::Meeting.arel_table[:id].gt(meeting.id)
            )
          )
        ).first
      end

      def prev_meeting
        return if search_collection.size < 2

        search_collection.order(:start_time, :id).where(
          Decidim::Meetings::Meeting.arel_table[:start_time].lt(meeting.start_time).or(
            Decidim::Meetings::Meeting.arel_table[:start_time].eq(meeting.start_time).and(
              Decidim::Meetings::Meeting.arel_table[:id].lt(meeting.id)
            )
          )
        ).last
      end

      def nav_paths
        return {} if meeting.blank?

        { prev_path: prev_meeting, next_path: next_meeting }.compact_blank.transform_values { |meeting| meeting_path(meeting) }
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

      def tab_panel_items
        @tab_panel_items ||= [
          {
            enabled: meeting.public_participants.any?,
            id: "participants",
            text: t("attending_participants", scope: "decidim.meetings.public_participants_list"),
            icon: "group-line",
            method: :cell,
            args: ["decidim/meetings/public_participants_list", meeting]
          },
          {
            enabled: !meeting.closed? && meeting.user_group_registrations.any?,
            id: "organizations",
            text: t("attending_organizations", scope: "decidim.meetings.public_participants_list"),
            icon: "community-line",
            method: :cell,
            args: ["decidim/meetings/attending_organizations_list", meeting]
          },
          {
            enabled: meeting.linked_resources(:proposals, "proposals_from_meeting").present?,
            id: "included_proposals",
            text: t("decidim/proposals/proposal", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Proposals::Proposal"),
            method: :cell,
            args: ["decidim/linked_resources_for", meeting, { type: :proposals, link_name: "proposals_from_meeting" }]
          },
          {
            enabled: meeting.linked_resources(:results, "meetings_through_proposals").present?,
            id: "included_meetings",
            text: t("decidim/accountability/result", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Accountability::Result"),
            method: :cell,
            args: ["decidim/linked_resources_for", meeting, { type: :results, link_name: "meetings_through_proposals" }]
          }
        ] + attachments_tab_panel_items(@meeting)
      end
    end
  end
end
