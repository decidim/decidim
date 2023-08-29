# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceProgramController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext
      helper Decidim::SanitizeHelper
      helper Decidim::Conferences::ConferenceProgramHelper
      participatory_space_layout only: :show

      helper_method :collection, :conference, :meeting_days, :meeting_component

      def show
        raise ActionController::RoutingError, "No meetings for this conference " if meetings.blank?

        enforce_permission_to :list, :program
        redirect_to decidim_conferences.conference_path(current_participatory_space) unless current_user_can_visit_space?
      end

      private

      def meeting_component
        return if params[:id].blank?

        @meeting_component ||= current_participatory_space.components.where(manifest_name: "meetings").find_by(id: params[:id])
      end

      def meetings
        return unless meeting_component&.published? || !meeting_component.presence

        @meetings ||= Decidim::Meetings::Meeting.where(component: meeting_component).visible_for(current_user).order(:start_time)
      end

      def meeting_days
        @meeting_days ||= meetings.map { |m| [m.start_time.to_date] }.uniq.flatten
      end

      alias collection meetings

      def current_participatory_space
        return unless params[:conference_slug]

        @current_participatory_space ||= OrganizationConferences.new(current_organization).query.where(slug: params[:conference_slug]).or(
          OrganizationConferences.new(current_organization).query.where(id: params[:conference_slug])
        ).first!
      end

      def conference
        current_participatory_space
      end
    end
  end
end
