# frozen_string_literal: true

module Decidim
  # This cell is used to generate a filter of activities types
  # Model is expected to be a list of types
  class ResourceTypesFilterCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper
    include Decidim::FiltersHelper
    include Decidim::LayoutHelper
    include Decidim::IconHelper

    private

    def resource_types
      return @resource_types if defined?(@resource_types)

      @resource_types = model.map do |klass|
        [klass, klass.constantize.model_name.human]
      end.sort_by(&:last)

      @resource_types.unshift(all_resource_types_option)
    end

    def id
      @id ||= options[:id] || "filters"
    end

    def form_path
      options[:form_path]
    end

    def filter_param_key
      @filter_param_key ||= options[:filter_param_key] || :resource_type
    end

    def filter_param
      @filter_param ||= params.dig(:filter, filter_param_key) || all_types_key
    end

    def filter
      options[:filter]
    end

    def all_resource_types_option
      [all_types_key, I18n.t(all_types_key, scope: "decidim.last_activities")]
    end

    def all_types_key
      @all_types_key ||= "all"
    end
  end
end
