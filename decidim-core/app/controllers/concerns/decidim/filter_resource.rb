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
      attr_reader :filter

      def initialize(filter, default_filter_params)
        @filter = filter
        @default_filter_params = default_filter_params
      end

      def method_missing(method_name, *_arguments)
        @filter.present? && @filter.has_key?(method_name) ? @filter[method_name] : super
      end

      def respond_to_missing?(method_name, include_private = false)
        @filter.present? && @filter.has_key?(method_name) || super
      end

      def to_tags
        @filter.reject do |k, v|
          v.blank? || @default_filter_params[k] == v || v.is_a?(Array) && v.reject(&:blank?).empty?
        end.inject([]) do |acc, (k,v)|
          if v.is_a? Array
            acc.concat(v.reject(&:empty?).map { |v| { name: k, value: v } })
          else
            acc << { name: k, value: v }
          end
          acc
        end
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
        @filter ||= Filter.new(filter_params, default_filter_params)
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

      def context_params
        {
          feature: current_feature,
          current_user: current_user
        }
      end
    end
  end
end
