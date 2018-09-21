# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable

    helper Decidim::ResourceHelper
    helper Decidim::FiltersHelper
    helper_method :resources, :activities

    def index
      @resource_types = search.results.pluck(:resource_type).uniq
      @resource_types_collection = @resource_types.map do |klass|
        [klass, klass.constantize.model_name.human]
      end
    end

    def resources
      @resources ||= activities.select(:resource_type, :resource_id).group_by(&:resource_type).flat_map do |resource_type, activities|
        resource_type.constantize.includes(component: { participatory_space: :organization }).where(id: activities.map(&:resource_id))
      end
    end

    def activities
      @activities ||= paginate(search.results)
    end

    def search_klass
      ActivitySearch
    end

    def context_params
      { organization: current_organization }
    end

    def default_filter_params
      {
        resource_type: "all"
      }
    end

    def default_search_params
      {
        scope: ActionLog.public
      }
    end
  end
end
