# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable
    include ::Webpacker::Helper
    include ::ActionView::Helpers::AssetUrlHelper
    include IconHelper

    helper Decidim::ResourceHelper
    helper Decidim::FiltersHelper

    helper_method :activities, :resource_types

    private

    def resource_types
      @resource_types ||= ActionLog.public_resource_types
    end

    def activities
      @activities ||= paginate(search.result)
    end

    def search_collection
      LastActivity.new(current_organization).query
    end

    def default_filter_params
      { with_resource_type: "all" }
    end
  end
end
