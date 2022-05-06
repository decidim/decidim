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
        (@filter.present? && @filter.has_key?(method_name)) || super
      end
    end

    included do
      helper_method :search, :filter_params, :filter

      private

      def search
        @search ||= search_with(filter_params)
      end

      def search_with(provided_params)
        search_collection.ransack(provided_params, context_params.merge(auth_object: current_user))
      end

      def search_collection
        raise NotImplementedError, "A search class is neeeded to filter resources"
      end

      def filter
        @filter ||= Filter.new(filter_params)
      end

      # Fetches the correct filter parameters from the request parameters in
      # order to limit the parameters which can be used for searching the
      # resources. Otherwise the user could pass extra search parameters from
      # the request using the Ransack API.
      def filter_params
        @filter_params = begin
          passed_params = params.to_unsafe_h[:filter].try(:symbolize_keys) || {}
          default_filter_params.merge(passed_params.slice(*default_filter_params.keys))
        end
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

      # If the controller responds to current_component, its is probably
      # searching against that component. Otherwise it is be likely to search
      # against a participatory space. The context params are passed to the
      # Ransack search classes which may be customized per model in case they
      # need this contextual information. For such searches, take a look at the
      # ResourceSearch class or any search class inheriting from that which
      # utilize this context information, such as the current user.
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
