# frozen_string_literal: true

# i18n-tasks-use t('decidim.conferences.conferences.show.already_have_an_account?')
# i18n-tasks-use t('decidim.conferences.conferences.show.are_you_new?')
# i18n-tasks-use t('decidim.conferences.conferences.show.sign_in_description')
# i18n-tasks-use t('decidim.conferences.conferences.show.sign_up_description')
module Decidim
  module Conferences
    # A controller that holds the logic to show Conferences in a
    # public layout.
    class ConferencesController < Decidim::Conferences::ApplicationController
      include ParticipatorySpaceContext
      include Paginable

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::SanitizeHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::Conferences::PartnersHelper

      helper_method :collection, :promoted_conferences, :conferences, :stats

      def index
        raise ActionController::RoutingError, "Not Found" if published_conferences.none?

        enforce_permission_to :list, :conference
      end

      def show
        enforce_permission_to :read, :process, process: current_participatory_space
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

      def collection
        @collection ||= paginate(conferences.query)
      end

      def promoted_conferences
        @promoted_conferences ||= conferences | PromotedConferences.new
      end

      def stats
        @stats ||= ConferenceStatsPresenter.new(conference: current_participatory_space)
      end
    end
  end
end
