# frozen_string_literal: true

module Decidim
  # Renders a collection of activities using a different cell for
  # each one.
  class ActivitiesCell < Decidim::ViewModel
    include Decidim::CardHelper
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    # Since we're rendering each activity separatedly we need to trigger
    # BatchLoader in order to accumulate all the ids to be found later.
    def show
      return if activities.blank?

      render
    end

    def activity_cell_for(activity)
      options = {
        show_author: (context[:user] != activity.user)
      }

      cell "#{activity.resource_type.constantize.name.underscore}_activity", activity, context: options
    rescue NameError
      cell "decidim/activity", activity, context: options
    end

    def activities
      @activities ||= last_activities.select do |activity|
        activity.visible_for?(current_user)
      end
    end

    def last_activities
      @last_activities ||= model.map do |activity|
        activity.organization_lazy
        activity.resource_lazy
        activity.participatory_space_lazy
        activity.component_lazy
        activity
      end
    end
  end
end
