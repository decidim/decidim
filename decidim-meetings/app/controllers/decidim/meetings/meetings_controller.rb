# frozen_string_literal: true

require "rqrcode"

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource
      include ComponentFilterable
      include Flaggable
      include Withdrawable
      include FormFactory
      include Paginable

      helper Decidim::ResourceVersionsHelper
      helper Decidim::ShortLinkHelper
      include Decidim::AttachmentsHelper
      include Decidim::SanitizeHelper

      helper_method :meetings, :meeting, :registration, :registration_qr_code_image, :search, :tab_panel_items

      before_action :add_additional_csp_directives, only: [:show]

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

        return if maybe_show_redirect_notice!
      end

      def edit
        enforce_permission_to(:update, :meeting, meeting:)

        @form = meeting_form.from_model(meeting)
      end

      def update
        enforce_permission_to(:update, :meeting, meeting:)

        @form = meeting_form.from_params(params)

        UpdateMeeting.call(@form, meeting) do
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

      def meetings
        is_past_meetings = params.dig("filter", "with_any_date")&.include?("past")
        @meetings ||= paginate(search.result.order(start_time: is_past_meetings ? :desc : :asc))
      end

      def registration
        @registration ||= meeting.registrations.find_by(user: current_user)
      end

      def registration_qr_code_image
        Base64.encode64(
          RQRCode::QRCode.new(registration.validation_code_short_link.short_url).as_png(size: 500).to_s
        ).gsub("\n", "")
      end

      def search_collection
        Meeting
          .where(component: current_component)
          .published
          .not_hidden
          .or(MeetingLink.find_meetings(component: current_component))
          .visible_for(current_user)
          .with_availability(
            filter_params[:with_availability]
          )
          .includes(
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

      def maybe_show_redirect_notice!
        return unless previous_space

        flash.now[:notice] = I18n.t(
          "meetings.show.redirect_notice",
          scope: "decidim.meetings",
          previous_space_url: request.referer,
          previous_space_name: decidim_escape_translated(previous_space.title),
          current_space_name: decidim_escape_translated(current_component.participatory_space.title)
        )
      end

      def previous_space
        return @previous_space if @previous_space
        return unless params[:previous_space]

        previous_space_class, previous_space_id = params[:previous_space].split("#")

        @previous_space = previous_space_class.constantize.find_by(id: previous_space_id)
        @previous_space
      rescue NameError, LoadError
        nil
      end
    end
  end
end
