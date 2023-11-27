# frozen_string_literal: true

module Decidim
  module Conferences
    class RegistrationTypesController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext

      helper_method :collection, :conference

      def index
        raise ActionController::RoutingError, "No registration types for this conference " if registration_types.empty? && current_participatory_space.registrations_enabled.empty?

        enforce_permission_to :list, :registration_types
      end

      private

      def registration_types
        @registration_types ||= current_participatory_space.registration_types.published
      end

      alias collection registration_types

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
