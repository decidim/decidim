# frozen_string_literal: true

module Decidim
  # The controller to handle the user's public profile page.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable

    helper Decidim::ResourceHelper
    helper Decidim::FiltersHelper
    helper_method :activities

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
        scope: ActionLog.public.includes(:resource)
      }
    end
  end
end
