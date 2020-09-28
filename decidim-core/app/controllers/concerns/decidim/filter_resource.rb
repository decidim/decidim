# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to filter resources
  module FilterResource
    extend ActiveSupport::Concern

    # Internal: Defines a class that will wrap in an object the URL params used by the filter.
    # this way we can use Rails' form helpers and have automatically checked checkboxes and
    # radio buttons in the view, for example.
    class Filter
      def initialize(filter)
        @filter = filter
      end

      def method_missing(method_name, *_arguments)
        @filter.present? && @filter.has_key?(method_name) ? @filter[method_name] : super
      end

      def respond_to_missing?(method_name, include_private = false)
        @filter.present? && @filter.has_key?(method_name) || super
      end
    end

    included do
      helper_method :search, :filter

      private

      def search
        @search ||= search_klass.new(search_params)
      end

      def search_klass
        raise NotImplementedError, "A search class is neeeded to filter resources"
      end

      def filter
        @filter ||= Filter.new(filter_params)
      end

      def search_params
        default_search_params
          .merge(filter_params)
          .merge(context_params)
      end

      def filter_params
        default_filter_params
          .merge(params.to_unsafe_h[:filter].try(:symbolize_keys) || {})
      end

      def default_search_params
        {}
      end

      def default_filter_params
        {}
      end

      def default_filter_category_params
        return "all" unless current_component.participatory_space.categories.any?

        ["all"] + current_component.participatory_space.categories.pluck(:id).map(&:to_s)
      end

      def default_filter_scope_params
        return "all" unless current_component.scopes.any?

        if current_component.scope
          ["all", current_component.scope.id] + current_component.scope.children.map { |scope| scope.id.to_s }
        else
          %w(all global) + current_component.scopes.pluck(:id).map(&:to_s)
        end
      end

      # If the controller responds to current_component, its search service uses the
      # base class Decidim::ResourceSearch; else it uses the ParticipatorySpaceSearch.
      # They need different context_params to set up the base_query:
      # - ResourceSearch uses `component`
      # - ParticipatorySpaceSearch uses `organization`
      # - Both use `current_user`
      # - Both need `organization` for localized searches in order to fetch the
      #   available locales from the organization in Decidim::ResourceSearch.
      def context_params
        context = {
          current_user: current_user,
          organization: current_organization
        }
        context[:component] = current_component if respond_to?(:current_component)

        context
      end
    end
  end
end
