# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserActivitiesController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FilterResource
    include Flaggable
    include HasProfileBreadcrumb

    helper Decidim::ResourceHelper
    helper_method :activities, :resource_types, :user

    def index
      raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
      raise ActionController::RoutingError, "Blocked User" if user.blocked? && !current_user&.admin?
    end

    private

    def user
      return unless params[:nickname]

      @user ||= current_organization.users.find_by("nickname = ?", params[:nickname].downcase)
    end

    def activities
      @activities ||= paginate(
        if own_activities?
          OwnActivities.new(current_organization, **activity_options).query.with_private_resources
        else
          PublicActivities.new(current_organization, **activity_options).query.with_all_resources
        end
      )
    end

    def activity_options
      {
        user:,
        current_user:,
        resource_name: filter.resource_type
      }
    end

    def own_activities?
      @own_activities ||= current_user == user
    end

    def default_filter_params
      { resource_type: nil }
    end

    def all_value
      "all"
    end

    def resource_types
      @resource_types = begin
        array = %w(Decidim::Proposals::CollaborativeDraft
                   Decidim::Comments::Comment
                   Decidim::Debates::Debate
                   Decidim::Initiative
                   Decidim::Meetings::Meeting
                   Decidim::Blogs::Post
                   Decidim::Proposals::Proposal)
        array << "Decidim::Budgets::Order" if own_activities?
        array
      end
    end
  end
end
