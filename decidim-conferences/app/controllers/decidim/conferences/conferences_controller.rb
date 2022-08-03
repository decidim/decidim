# frozen_string_literal: true

module Decidim
  module Conferences
    # A controller that holds the logic to show Conferences in a
    # public layout.
    class ConferencesController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: :show

      redesign_participatory_space_layout

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::Conferences::PartnersHelper

      helper_method :collection, :promoted_conferences, :conferences, :stats

      def index
        redirect_to "/404" if published_conferences.none?

        enforce_permission_to :list, :conference
      end

      def show
        check_current_user_can_visit_space
      end

      def user_diploma
        render layout: "decidim/diploma"
      end

      private

      def current_participatory_space
        return unless params[:slug]

        @current_participatory_space ||= OrganizationConferences.new(current_organization).query.where(slug: params[:slug]).or(
          OrganizationConferences.new(current_organization).query.where(id: params[:slug])
        ).first!
      end

      def published_conferences
        @published_conferences ||= OrganizationPublishedConferences.new(current_organization, current_user)
      end

      def conferences
        @conferences ||= OrganizationPrioritizedConferences.new(current_organization, current_user)
      end

      alias collection conferences

      def promoted_conferences
        @promoted_conferences ||= conferences | PromotedConferences.new
      end

      def stats
        @stats ||= ConferenceStatsPresenter.new(conference: current_participatory_space)
      end
    end
  end
end
