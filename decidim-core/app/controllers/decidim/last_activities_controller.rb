# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable
    include ::Shakapacker::Helper
    include ::ActionView::Helpers::AssetUrlHelper
    include IconHelper
    include HasSpecificBreadcrumb

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
      LastActivity.new(current_organization, current_user:).query
    end

    def default_filter_params
      { with_resource_type: "all" }
    end

    def breadcrumb_item
      {
        label: t("decidim.last_activities.name"),
        active: true,
        url: last_activities_path
      }
    end
  end
end
