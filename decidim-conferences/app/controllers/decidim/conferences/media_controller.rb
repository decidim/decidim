# frozen_string_literal: true

module Decidim
  module Conferences
    class MediaController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext
      helper Decidim::Conferences::MediaAttachmentsHelper
      helper Decidim::SanitizeHelper

      participatory_space_layout only: :index

      helper_method :collection, :conference

      def index
        raise ActionController::RoutingError, "No media_links for this conference " if media_links.empty? && current_participatory_space.attachments.empty?

        enforce_permission_to :list, :media_links
        redirect_to decidim_conferences.conference_path(current_participatory_space) unless current_user_can_visit_space?
      end

      private

      def media_links
        @media_links ||= current_participatory_space.media_links
      end

      alias collection media_links

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
