# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserTimelineController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FilterResource
    include Flaggable

    helper Decidim::ResourceHelper
    helper_method :activities, :resource_types, :user

    def index
      raise ActionController::RoutingError, "Not Found" if current_user != user
    end

    private

    def user
      @user ||= Decidim::User.find_by(
        organization: current_organization,
        nickname: params[:nickname]
      )
    end

    def activities
      @activities ||= paginate(
        PublicActivities.new(
          current_organization,
          scopes: current_user.interested_scopes,
          follows: follows,
          resource_name: filter.resource_type
        ).query.with_resource_type("all")
      )
    end

    def follows
      @follows ||= Decidim::Follow.where(user: user)
    end

    def default_filter_params
      { resource_type: nil }
    end

    def resource_types
      @resource_types = %w(Decidim::Proposals::CollaborativeDraft
                           Decidim::Comments::Comment
                           Decidim::Debates::Debate
                           Decidim::Initiative
                           Decidim::Meetings::Meeting
                           Decidim::Blogs::Post
                           Decidim::Proposals::Proposal
                           Decidim::Consultations::Question)
    end
  end
end
