# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class LastActivitiesController < Decidim::ApplicationController
    include FilterResource
    include Paginable

    helper Decidim::ResourceHelper
    helper Decidim::FiltersHelper

    helper_method :activities, :resource_types

    private

    def resource_types
      return @resource_types if defined?(@resource_types)

      @resource_types = ActionLog.public_resource_types.sort_by do |klass|
        klass.constantize.model_name.human
      end

      @resource_types = @resource_types.map do |klass|
        [klass, klass.constantize.model_name.human]
      end

      @resource_types << ["all", I18n.t("decidim.last_activities.all")]
    end

    def activities
      @activities ||= paginate(search.result)
    end

    def search_collection
      ActionLog
        .where(visibility: %w(public-only all))
        .where(organization: current_organization)
    end

    def default_filter_params
      { with_resource_type: "all" }
    end
  end
end
