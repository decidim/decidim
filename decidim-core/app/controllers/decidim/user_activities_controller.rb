# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserActivitiesController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FilterResource
    include Flaggable

    helper Decidim::ResourceHelper
    helper_method :activities, :resource_types, :user

    def index
      raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
      raise ActionController::RoutingError, "Blocked User" if user.blocked? && !current_user&.admin?
    end

    private

    def user
      @user ||= current_organization.users.find_by(nickname: params[:nickname])
    end

    def activities
      @activities ||= begin
        paginate(
          activity_class.new(
            current_organization,
            user: user,
            current_user: current_user,
            resource_name: filter.resource_type
          ).query.public_send(activity_method, *activity_arguments)
        )
      end
    end

    def activity_method
      own_activities? ? :with_private_resources : :with_resource_type
    end

    def activity_arguments
      own_activities? ? [] : %w(all)
    end

    def activity_class
      own_activities? ? OwnActivities : PublicActivities
    end

    def own_activities?
      @own_activities ||= current_user == user
    end

    def default_filter_params
      { resource_type: nil }
    end

    def resource_types
      @resource_types = begin
        array = %w(Decidim::Proposals::CollaborativeDraft
                   Decidim::Comments::Comment
                   Decidim::Debates::Debate
                   Decidim::Initiative
                   Decidim::Meetings::Meeting
                   Decidim::Blogs::Post
                   Decidim::Proposals::Proposal
                   Decidim::Consultations::Question)
        array << "Decidim::Budgets::Order" if own_activities?
        array
      end
    end
  end
end
