# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceSpeakersController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext

      participatory_space_layout only: :index

      helper_method :collection, :conference

      def index
        raise ActionController::RoutingError, "No speakers for this conference " if speakers.empty?
        enforce_permission_to :list, :speakers
        redirect_to decidim_conferences.conference_path(current_participatory_space) unless current_user_can_visit_space?
      end

      private

      def speakers
        @speakers ||= current_participatory_space.speakers
      end

      alias collection speakers

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
