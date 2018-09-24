# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable

    helper Decidim::ResourceHelper
    helper Decidim::FiltersHelper

    helper_method :activities

    def index
      @resource_types = search.resource_types
      @resource_types = @resource_types.sort_by do |klass|
        klass.constantize.model_name.human
      end
      @resource_types = @resource_types.map do |klass|
        [klass, klass.constantize.model_name.human]
      end
      @resource_types << ["all", "All"]
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
  end
end
