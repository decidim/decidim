# frozen_string_literal: true

module Decidim
  # Renders a collection of activities using a different cell for
  # each one.
  class ActivitiesCell < Decidim::ViewModel
    include Decidim::CardHelper
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    delegate :current_organization, to: :controller

    # Since we're rendering each activity separatedly we need to trigger
    # BatchLoader in order to accumulate all the ids to be found later.
    def show
      return if activities.blank?

      activities.map do |activity|
        activity.organization_lazy
        activity.resource_lazy
        activity.participatory_space_lazy
        activity.component_lazy
      end

      render
    end

    def cell_for(activity)
      "#{activity.resource_type.constantize.name.underscore}_activity"
    end

    def activities
      model
    end
  end
end
